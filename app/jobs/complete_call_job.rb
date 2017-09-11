class CompleteCallJob < ApplicationJob
  queue_as :conference

  def perform(appointment_id)
    # Terminate the conference room using the twilio api
    account_sid = Settings.Twilio.account_sid
    auth_token  = Settings.Twilio.auth_token

    client ||= Twilio::REST::Client.new(account_sid, auth_token)

    room_sid = Core::Appointment.find(appointment_id).conference_name
    room = client.video.rooms(room_sid).update(status: 'completed')
    # TODO: notifiy both student and tutor that the conference room terminated
  end
end
