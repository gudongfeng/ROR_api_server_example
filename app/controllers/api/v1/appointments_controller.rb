class Api::V1::AppointmentsController < Api::ApiController
  before_action :check_for_student_valid_authtoken, :only => [
                                                  :all_appointments_student,
                                                  :manually_terminate_appointment]
  before_action :check_for_tutor_valid_authtoken, :only =>:all_appointments_tutor
  before_action :set_locale

  # Return all the appointment for this student
  def all_appointments_student
    if @student && @student.remember_expiry > Time.now
      # Only get the appointments with specific state
      appointments = @student.appointments
      message = []
      appointments.each do |appointment|
        message << appointment.to_json
      end
      render :json => {:appointment_number => appointments.length}, :status => 200
    else
      json_error_message 401, (I18n.t 'error.messages.login')
    end
  end

  # Return all the appointment for this teacher
  def all_appointments_tutor
    if @tutor && @tutor.remember_expiry > Time.now
      # Only get the appointments with specific state
      appointments = @tutor.appointments
      message = []
      appointments.each do |appointment|
        message << appointment.to_json
      end
      # return the total number of the appointment of this tutor
      render :json => {:appointment_number => appointments.length}, :status => 200
    else
      json_error_message 401, (I18n.t 'error.messages.login')
    end
  end

  # Student can manually terminate the appointment
  def manually_terminate_appointment
    if params[:appointment_id]
      if @student && @student.remember_expiry > Time.now
        # student finished the appointment
        appointment = Core::Appointment.find params[:appointment_id]
        if appointment
          # remove the previous callhangup schedule
          Sidekiq::Status.cancel appointment.call_hangup unless  appointment.call_hangup.nil?
          appointment.update_attribute(:call_hangup, nil)
          # remove the call_speak_reminder
          Sidekiq::Status.cancel appointment.tutor_sidekiq_job_id if appointment.tutor_sidekiq_job_id
          Sidekiq::Status.cancel appointment.student_sidekiq_job_id if appointment.student_sidekiq_job_id

          # perform the callhangup
          CallHangup.perform_async appointment.id
          render :json => {:message => (I18n.t 'success.messages.end_appointment')}
        end
      else
        json_error_message 401, (I18n.t 'error.messages.login')
      end
    else
      json_error_message 400, (I18n.t 'error.messages.parameters')
    end
  end

  # Get the appointment information according to appointment id
  def get_appointment_from_id
    if params && params[:appointment_id]
      appointment = Core::Appointment.find_by_id(params[:appointment_id]);
      if appointment
        render :json => appointment.to_json, :status => 200
      else
        json_error_message 404, (I18n.t 'error.messages.no_appointment')
      end
    else
      json_error_message 400, (I18n.t 'error.messages.parameters')
    end
  end

private

  # Define the require params for create the appointment
  def appointment_create_params
    params[:appointment][:state] = 'available'
    params[:appointment][:amount] = Settings.init_one_appointment_price
    params[:appointment][:state_start_time] = Time.now

    # Parse the string to time object
    params[:appointment][:start_time] = Time.parse(
        params[:appointment][:start_time])
    params[:appointment][:end_time] = Time.parse(
        params[:appointment][:end_time])
    # generate order_no for futher references
    params[:appointment][:order_no] = SecureRandom.hex(6)
    params.require(:appointment).permit(:state, :start_time, :end_time,
                                        :state_start_time, :amount, :order_no)
  end

  # Check the student authtoken
  def check_for_student_valid_authtoken
    authenticate_or_request_with_http_token do |token, options|
      @student = Core::Student.find_by(remember_token: token)
    end
  end

  # Check the tutor authtoken
  def check_for_tutor_valid_authtoken
    authenticate_or_request_with_http_token do |token, options|
      @tutor = Core::Tutor.find_by(remember_token: token)
    end
  end

  # Check the availability of this time slot
  def check_tutor_availability? time, tutor
    # get the all the occupy time for the tutor
    appointments = tutor.appointments.where(state: 'confirmed')
    appointments.each do |appointment|
      if Time.at(time.to_i) == Time.at(appointment.start_time.to_i)
        return false
      end
    return true
    end
  end

  # Arrange the appointment to the tutor automatically
  def arrange_appointment_to_tutor appointment
    # Go through all the available tutors and arrange the appointment
    Core::Tutor.all.each do |tutor|
      if check_tutor_availability? appointment.start_time, tutor
        # If the Tutor is available, set this appointments to this tutor
        if appointment.update_attribute :tutor_id, tutor.id
          # successfully arrange the appointment to this tutor
          appointment.update_attribute :state, 'confirmed'
          appointment.update_attribute :state_start_time, Time.now
          # break the loop if the arrangement was made successfully
          return tutor
        end
      end
    end
    return nil
  end

  # Arrange the appointment to the tutor randomly
  def arrange_appointment_to_tutor_random appointment
    # Go through all the available tutors and arrange the appointment
    Core::Tutor.all.shuffle.each do |tutor|
      if check_tutor_availability? appointment.start_time, tutor
        # If the Tutor is available, set this appointments to this tutor
        if appointment.update_attribute :tutor_id, tutor.id
          # successfully arrange the appointment to this tutor
          appointment.update_attribute :state, 'confirmed'
          appointment.update_attribute :state_start_time, Time.now
          # break the loop if the arrangement was made successfully
          return tutor
        end
      end
    end
    return nil
  end

end