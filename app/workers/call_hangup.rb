class CallHangup < ActionController::Base
  include Sidekiq::Worker

  def perform appointment_id
    # finished the call, change the tutor and student state to paying
    appointment = Core::Appointment.find appointment_id
    if appointment
      # finished the appointment
      appointment.update_attribute :state, 'finished'
      # change the student state
      appointment.student.change_state 'paying' if appointment.student.state.eql? 'meeting'
      # change the tutor state to rating
      appointment.tutor.change_state 'rating' if appointment.tutor.state.eql? 'meeting'
    end
  end
end