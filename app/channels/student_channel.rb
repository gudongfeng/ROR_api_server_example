class StudentChannel < ApplicationCable::Channel
  def subscribed
    # each student subscribe to a single channel
    stream_from "student_#{current_user.id}"
  end

  def unsubscribed
    # student finished request
  end

  # Student make a request
  #
  # Args:
  #   data["plan_id"]: student request plan_id
  # Returns:
  #   success: broadcast request to tutor
  #   fail: broadcast fail message to student
  def request(data)
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
    end
  end
end
