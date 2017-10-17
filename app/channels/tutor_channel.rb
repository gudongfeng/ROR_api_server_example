class TutorChannel < ApplicationCable::Channel
  # Tutor go online
  def subscribed
    stream_from "tutor_#{current_user.id}"
    # Add the tutor to the online queue
    TutorOnlineQueue.instance.push(current_user.id)
  end

  # Tutor go offline
  def unsubscribed
    # Remove the tutor from the tutor online queue
    TutorOnlineQueue.instance.remove(current_user.id)
    stop_all_streams
  end

  # Tutor response the student appointment request
  #
  # Args:
  #   data['response'](mandatory):   tutor response result
  #   data['message']['student_id']: request student id
  #   data['message']['plan_id']:    request plan id
  def response(data)
    if data['response'] == 'accept'
      tutor_id   = current_user.id
      student_id = data['message']['student_id']
      plan_id    = data['message']['plan_id']
      
      # Check if the request have been accepted or cancel.
      student = Core::Student.find(student_id)
      if student.state != 'requesting'
        # Notify the tutor that request has been cancel or accepted
        msg = I18n.t('tutors.appointment.occupied')
        MessageBroadcastJob.perform_later(msg, 'notification', tutor_id: tutor_id)
        return
      else
        # Keep going, change the student state
        student.change_state('meeting')
      end

      # Create an appointment
      appointment = current_user.appointments
                                .create(create_appointment_params(plan_id))
      appointment.update_attribute(:student_id, student_id)

      # Start a conversation
      MakeCallJob.set(wait: Settings.call_delay_time)
                 .perform_later(student_id, tutor_id, appointment.id)
      # Notify the tutor and student that the call will start in several minutes
      msg = I18n.t('appointment.conference_room.call_delay',
                   time: Settings.call_delay_time)
      MessageBroadcastJob.perform_later(msg, 'notification',
                                        student_id: student_id,
                                        tutor_id: tutor_id)
      # Notify the tutor and student before the call end
      call_length       = Settings.instance_eval("call_length_plan_#{plan_id}")
      call_end_reminder = Settings.call_speak_reminder_time
      msg = I18n.t('appointment.conference_room.call_end',
                   time: call_end_reminder)
      MessageBroadcastJob.set(wait: call_length - call_end_reminder)
                         .perform_later(msg, 'notification',
                                        student_id: student_id,
                                        tutor_id: tutor_id)
      # Terminate the conference room in serveral mins
      job = CompleteCallJob.set(wait: call_length).perform_later(appointment.id)
      # Store the jid for the complete call job for later usage.
      jid = job.provider_job_id
      appointment.update_attribute(:complete_call_jid, jid)

    else
      current_user.update_attribute(:decline_count,
                                    current_user.decline_count + 1)
      # Add the tutor back to queue
      TutorOnlineQueue.instance.push(tutor_id)
    end
  end

  private

  def create_appointment_params(plan_id)
    call_length  = Settings.instance_eval("call_length_plan_#{plan_id}")
    tutor_earned = Settings.instance_eval("tutor_earned_plan_#{plan_id}")
    amount       = Settings.instance_eval("price_plan_#{plan_id}")
    { start_time: Time.now, end_time: Time.now + call_length,
      plan_id: plan_id, tutor_earned: tutor_earned, amount: amount }
  end
end
