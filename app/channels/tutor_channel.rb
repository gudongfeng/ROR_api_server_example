class TutorChannel < ApplicationCable::Channel
  def subscribed
    stream_from "tutor_#{current_user.id}"
    # add the tutor to the online queue
    TutorOnlineQueue.instance.push(current_user.id)
  end

  # tutor go offline
  def unsubscribed
    # remove the tutor from the tutor online queue
    TutorOnlineQueue.instance.remove(current_user.id)
    stop_all_streams
  end

  # Args
  #   data['message']['student_id']: request student id
  #   data['message']['plan_id']:    request plan id
  #   data['response']:   tutor response result
  def response(data) 
    # tutor accept or decline the request
    if data['response'] == 'accept'
      # create an appointment
      appointment = current_user.appointments.create(
        create_appointment_params data['message']['plan_id'])
      appointment.update_attribute(:student_id, data['message']['student_id'])
      # create a job to start a conversation
      MakeCallJob.set(wait: Settings.call_dealy_time).perform_later(
        data['message']['student_id'], current_user.id)
      # notify the tutor that the call will start in several minutes
      msg = I18n.t('appointment.conference_room.call_delay', 
                   time: Settings.call_delay_time)
      TutorMessageBroadcastJob.perform_later(current_user.id, 'notification', msg)
      # TODO: notification for the calling end

      # terminate the conference room in serveral mins
      CompleteCallJob.set(wait: Settings.instance_eval("call_length_plan_#{plan_id}"))\
        .perform_later()
    elsif data['response'] == 'decline'
      current_user.update_attribute(:decline_count, current_user.decline_count+1)
      # add the tutor back to queue
      TutorOnlineQueue.instance.push(current_user.id)
    else
      current_user.update_attribute(:decline_count, current_user.decline_count+1)
      # add the tutor back to queue
      TutorOnlineQueue.instance.push(current_user.id)
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
