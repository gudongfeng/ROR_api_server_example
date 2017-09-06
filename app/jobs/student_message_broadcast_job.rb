class StudentMessageBroadcastJob < ApplicationJob
  queue_as :student_message

  # Args
  #   student_id
  #   type:    message type ('error', 'join_conference')
  #   message: message content
  def perform(student_id, type, message)
    request = { "type": type,
                "message": message }
    ActionCable.server.broadcast("student_#{student_id}",
                                 request.as_json)
  end
end
