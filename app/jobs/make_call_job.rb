class MakeCallJob < ApplicationJob
  queue_as :conference

  attr_accessor :client
  
  def perform(student_id, tutor_id, appointment_id)
    # Twilio account info
    account_sid = Settings.Twilio.account_sid
    auth_token  = Settings.Twilio.auth_token
    api_key     = Settings.Twilio.api_key
    api_secret  = Settings.Twilio.api_secret
    identity    = Rails.application.secrets.secret_key_base
    
    # Create an Access Token
    token = Twilio::JWT::AccessToken.new(account_sid,
                                           api_key,
                                           api_secret)
    token.identity = identity
    # Cretea a Twilio client
    client ||= Twilio::REST::Client.new(account_sid,
                                        auth_token)
    
    # Create a room and save the room id to appointment
    room_name = (0...50).map { ('a'..'z').to_a[rand(26)] }.join
    room = client.video.rooms.create(unique_name: room_name)
    Core::Appointment.find(appointment_id)
                     .update_attribute(:conference_name, room.sid)

    # Send the token and room information to both student and tutor
    grant = Twilio::JWT::AccessToken::VideoGrant.new
    grant.room = room_name
    token.add_grant(grant)

    # Send conference room connection info to both tutor and student
    infos = { token: token.to_jwt, room_name: room_name }
    MessageBroadcastJob.perform_later(infos, 'join_conference',
                                      student_id = student_id,
                                      tutor_id = tutor_id)
  end
end
