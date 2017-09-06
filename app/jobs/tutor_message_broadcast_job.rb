class TutorMessageBroadcastJob < ApplicationJob
  queue_as :tutor_message

  # Args
  #   student_id
  #   type:    message type ('error', 'comming_request', 
  #                          'join_conference', 'notification')
  #   message: message content
  def perform(tutor_id, type, message)
    request = { "type": type,
                "message": message }
    ActionCable.server.broadcast("tutor_#{tutor_id}",
                                  request.as_json)
  end
end
