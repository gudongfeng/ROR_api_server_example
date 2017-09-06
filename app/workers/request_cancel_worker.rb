class RequestCancelWorker < ActionController::Base
  include Sidekiq::Worker

  PREFIX = "RequestCancelWorker: "

  def perform student_id, session_id
    student = Core::Student.find_by_id(student_id)
    rv = student.request_cancel_look_for_tutors(session_id)
    if rv == 'success'
    	p PREFIX + "Successfully cancelled student_id:#{student_id}'s request for looking tutors"
    else
    	p PREFIX + "Failed cancelling student_id:#{student_id}'s request for looking tutors due to #{rv}"
    end
  end

end