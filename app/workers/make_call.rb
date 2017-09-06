class MakeCall < ActionController::Base
  include Sidekiq::Worker

  def init
    @AUTH_ID = Settings.Plivo.auth_id
    @AUTH_TOKEN = Settings.Plivo.auth_token
  end

  def perform student_phone, tutor_phone, appointment_id
    init
    appointment = Core::Appointment.find appointment_id
    if appointment
      # change the tutor and the student state
      appointment.student.change_state 'meeting'
      appointment.tutor.change_state 'meeting'
      appointment.student.send_push('成功拨打电话')
      # make the call
      p = RestAPI.new(@AUTH_ID, @AUTH_TOKEN)
      params = {
          'to' => "#{student_phone}<#{tutor_phone}",
          'from' => "#{Settings.income_call_number}", # The phone number to be used as the caller id
          'answer_url' => Settings.heroku_server + '/api/v1/voice/response/conference?appointmentID='+"#{appointment_id}",
          'hangup_url' => Settings.heroku_server + '/api/v1/voice/hangup?appointmentID='+"#{appointment_id}"
      }
      p.make_call(params)
    end
  end

end