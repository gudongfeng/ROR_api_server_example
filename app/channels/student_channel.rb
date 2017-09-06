class StudentChannel < ApplicationCable::Channel
  def subscribed
    # each student subscribe to a single channel
    stream_from "student_#{current_user.id}"
  end

  def unsubscribed
    # student finished request
  end

  # Student make a request
  # Args:
  #   data["plan_id"]: student request plan_id
  # Returns:
  #   success: broadcast request to tutor
  #   fail: broadcast fail message to student
  def request(data)
    tutors = TutorOnlineQueue.instance.poll(Settings.single_notification_tutor_count)
    if !tutors.empty?
      # broadcast the student request to tutors
      for tutor_id in tutors
        message = { student_id: current_user.id, plan_id: data['plan_id'] }
        TutorMessageBroadcastJob.perform_later(
          tutor_id, 'comming_request', message)
      end
    else
      # tutor is not available
      StudentMessageBroadcastJob.perform_later(
        current_user.id, 'error',
        I18n.t('students.errors.appointment.busy'))
    end
  end
end
