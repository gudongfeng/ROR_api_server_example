class MakeCallJob < ApplicationJob
  queue_as :conference

  attr_accessor :client
  
  def perform(student_id, tutor_id)
    # twilio account info
    account_sid = Settings.Twilio.account_sid
    auth_token  = Settings.Twilio.auth_token
    api_key     = Settings.Twilio.api_key
    api_secret  = Settings.Twilio.api_secret
    identity    = Rails.application.secrets.secret_key_base
    
    # create an Access Token
    token = Twilio::JWT::AccessToken.new(account_sid,
                                           api_key,
                                           api_secret)
    token.identity = identity
    # Cretea a Twilio client
    client ||= Twilio::REST::Client.new(account_sid,
                                        auth_token)
    
    # create a room and ask tutor and student to join to the room
    room_name = (0...50).map { ('a'..'z').to_a[rand(26)] }.join
    client.video.rooms.create(unique_name: room_name)

    # send the token and room information to both student and tutor
    grant = Twilio::JWT::AccessToken::VideoGrant.new
    grant.room = room_name
    token.add_grant(grant)

    # send conference room connection info to both tutor and student
    infos = { token: token.to_jwt, room_name: room_name }
    StudentMessageBroadcastJob.perform_later(student_id, 'join_conference', infos)
    TutorMessageBroadcastJob.perform_later(tutor_id, 'join_conference', infos)
  end
end
