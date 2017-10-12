class MessageBroadcastJob < ApplicationJob
  queue_as :message

  # Broadcast message to student or tutor
  #
  # Args
  #   message: String/Hash, message content
  #   type:    String, message type ('error', 'join_conference',
  #                                  'notification', 'comming_request')
  #   ids:     Hash, example: { student_id: <id>, tutor_id: <id> } 
  def perform(message, type, **ids)
    types = ['error', 'notification', 'join_conference', 'comming_request']
    if types.include?(type)
      request = { "type": type,
                  "message": message }
      if !ids[:student_id].nil?
        ActionCable.server.broadcast("student_#{ids[:student_id]}", request.as_json)
      end
      if !ids[:tutor_id].nil?
        ActionCable.server.broadcast("tutor_#{ids[:tutor_id]}", request.as_json)
      end
    else
      raise 'Error message type'
    end
  end
end
