class CompleteCallJob < ApplicationJob
  queue_as :conference

  def perform(appointment_id)
    # Terminate the conference room using the twilio api
    account_sid = Settings.Twilio.account_sid
    auth_token  = Settings.Twilio.auth_token

    client ||= Twilio::REST::Client.new(account_sid, auth_token)

    appointment = Core::Appointment.find(appointment_id)
    room_sid = appointment.conference_name
    begin
      client.video.rooms(room_sid).update(status: 'completed')
    rescue Twilio::REST::RestError
      # Skip the error
    end

    
    # Notifiy both student and tutor that the conference room terminated
    msg = I18n.t('appointment.conference_room.call_terminated')
    MessageBroadcastJob.perform_later(msg, 'notification',
                                      student_id: appointment.student_id,
                                      tutor_id: appointment.tutor_id)
    # Add the tutor back to the queue
    TutorOnlineQueue.instance.push(appointment.tutor_id)
  end
end
