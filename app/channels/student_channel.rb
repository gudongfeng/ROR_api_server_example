class StudentChannel < ApplicationCable::Channel
  def subscribed
    # each student subscribe to a single channel
    stream_from "student_#{current_user.id}"
    # studnet go online
    current_user.change_state('online')
  end

  def unsubscribed
    # student go offline
    current_user.change_state('offline')
  end

  # Student make a request
  #
  # Args:
  #   data["plan_id"]: student request plan_id
  # Returns:
  #   success: broadcast request to tutor
  #   fail: broadcast fail message to student
  def request(data)
    # student start requesting
    current_user.change_state('requesting')
    fetch_tutor_count = Settings.single_notification_tutor_count
    tutors = TutorOnlineQueue.instance.poll(fetch_tutor_count)
    if !tutors.empty?
      # broadcast the student request to tutors
      for tutor_id in tutors
        message = { student_id: current_user.id, plan_id: data['plan_id'] }
        MessageBroadcastJob.perform_later(message,
                                          'comming_request',
                                          tutor_id: tutor_id)
      end
    else
      # tutor is not available
      MessageBroadcastJob.perform_later(
        I18n.t('students.errors.appointment.busy'),
        'error', student_id: current_user.id)
      # student back to online state
      current_user.change_state('online')
    end
  end

  # TODO: Student cancel the request
  def cancel()
    if current_user.state == 'requesting'
      current_user.change_state('online')
    else
      # Notify student that he is not in requesting state
    end
  end

  # Student extends the call
  #
  # Args:
  #   data['job_id']: the job id of sidekiq worker
  def extend(data)
    # Get the appointment
    appointment = current_user.appointments.last
    student_id  = current_user.id
    tutor_id    = appointment.tutor.id
    # Get the sidekiq job
    job         = Sidekiq::ScheduledSet.new.find_job(data['job_id'])
    new_time    = job.at + Settings.call_extend_time

    if job.reschedule(new_time)
      # update the appointment cost and call time
      appointment.update_attributes(:amount => (appointment.amount +
                                                Settings.call_extend_cost),
                                    :tutor_earned => (appointment.tutor_earned +
                                                      Settings.call_extend_earned))
      # TODO: notify the student and the tutor
      msg = I18n.t('appointment.conference_room.call_extend', 
                   time: Settings.call_extend_time)
      MessageBroadcastJob.perform_later(msg, 'notification',
                                        student_id: student_id,
                                        tutor_id: tutor_id)
    else
      msg = I18n.t('students.errors.appointment.call_extend')
      MessageBroadcastJob.perform_later(msg, 'notification',
                                        student_id: student_id)
    end
  end
end
