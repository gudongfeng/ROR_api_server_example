class MessageBroadcastJob < ApplicationJob
  queue_as :message

  # Broadcast message to student or tutor
  #
  # Args
  #   message: message content
  #   type:    message type ('error', 'join_conference', 'notification')
  #   student_id: student id
  #   tutor_id:   tutor id
  def perform(message, type, student_id=nil, tutor_id=nil)
    types = ['error', 'notification', 'join_conference', 'comming_request']
    if types.include?(type)
      request = { "type": type,
                  "message": message }
      if !student_id.nil?
        ActionCable.server.broadcast("student_#{student_id}", request.as_json)
      end
      if !tutor_id.nil?
        ActionCable.server.broadcast("tutor_#{tutor_id}", request.as_json)
      end
    else
      raise 'Error message type'
    end
  end
end
