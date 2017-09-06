class TutorWorker < ActionController::Base
  include Sidekiq::Worker

  PREFIX = "Tutorlistener: "

  def perform request_id
    request = Core::Request.find_by_id(request_id)
    if request.reply('decline')
      p PREFIX + "Tutor_id: #{request.tutor.id} failed to reply within #{Settings.Reservation.tutor_reply_time} seconds, decline by default"
    else
      p PREFIX + "request #{request.id} replied, skip default decline"
    end
  end

end