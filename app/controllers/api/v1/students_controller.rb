class Api::V1::StudentsController < Api::ApiController
  prepend_before_action :authenticate_student_request,
    :only => [:show, :edit, :reset_password, :get_status, :rate,
              :send_verification_code, :destroy, :activate_account,
              :appointments]
  before_action :activation_check,
    :only => [:show, :edit, :reset_password, :get_status,
              :send_verification_code, :destroy, :rate, :appointments]

  attr_reader :current_student

  # Student sign up function
  api :POST, '/students/signup', 'student sign up'
  param :student, Hash, :desc => 'student parameters' do
    param :name, String, :desc => 'student name', :required => true
    param :phoneNumber, String, :desc => 'student phone number',
          :required => true
    param :password, String, :desc => 'password', :required => true
    param :password_confirmation, String, :desc => 'confirmation of password',
          :required => true    
    param :country_code, [86, 1], :desc => '86/1 China/America & anada',
          :required => true
    param :gender, ['male', 'female'], :required => true
    param :picture, String, :desc => 'picture url'
  end
  formats ['JSON']
  error 400, 'parameter missing'
  error 403, 'invalid parameter'
  error 422, 'parameter value error'
  def create
    unless params && params[:student] && params[:student][:password] &&
        params[:student][:password_confirmation] && params[:student][:name] &&
        params[:student][:phoneNumber] && params[:student][:gender] &&
        params[:student][:country_code]
      return render_params_missing_error 
    else
      # Create a new student
      student = Core::Student.new(student_signup_params)

      return save_model_error student unless student.save
      # used to send an activation email to user / disabled for demo purpose
      # @student.send_activation_email
      # student.activate

      # send the verification code sms to the student
      student.send_verification_sms
      render :json => { :message => I18n.t('students.create.success'),
                        :student_id => student.id }, :status => :ok
    end
  end

  # Activate student account according to the verification code
  api :POST, '/students/activate_account', 'activate student'
  param :verification_code, String, :desc => "verification code", required: true
  header 'Authorization', "authentication token has to be passed as part
    of the request.", required: true
  formats ['JSON']
  error 400, 'parameter missing'
  error 401, 'unauthorized, account not found'
  error 401, 'verification code is wrong'
  def activate_account
    unless params && params[:verification_code]
      return render_params_missing_error
    else
      code = current_student.verification_code
      # error handler
      return render_error(I18n.t('students.errors.verification_code.missing'),
                          :not_found) if code.nil?
      # If the verification code doesn't match
      return render_error(I18n.t('students.errors.verification_code.invalid'),
                          :unauthorized) if !code.to_i.eql?(params[:verification_code].to_i)
      # activate the account
      current_student.activate
      render_message(I18n.t 'students.activate_account.success')
    end
  end

  # Edit the student information
  api :PATCH, '/students/info', 'edit the student information'
  param :student, Hash, :desc => 'student parameters' do
    param :name, String, :desc => 'student name'
    param :email, String, :desc => 'student email'
    param :device_token, String, :desc => 'device token'
    param :picture, String, :desc => 'student picture url'
    param :gender, ['male', 'female'], :desc => 'student gender'
  end
  header 'Authorization', "authentication token has to be passed as part
    of the request.", required: true
  error 400, 'parameter missing'
  error 401, 'unauthorized, account not found'
  error 412, 'account not activate'
  error 422, 'parameter value error'
  def edit
    if params && params[:student]
      return save_model_error current_student unless 
        current_student.update_attributes(student_edit_params)
      render_message(I18n.t 'students.edit.success')
    else
      return render_params_missing_error
    end
  end

  # Get student information
  api :GET, '/students/info', 'get the information of a single student'
  header 'Authorization', "authentication token has to be passed as part
   of the request.", required: true
  error 401, 'unauthorized, account not found'
  error 412, 'account not activate'
  def show
    render json: current_student, :status => :ok
  end

  # Update the password once the verification process has done
  api :POST, '/students/reset_password', '[(step 2,3) for resetting the password],
    you need to call send_verification_code first to send an sms message to student,
    verify the verification code only if password and password confirmation absent'
  header 'Authorization', "authentication token has to be passed as part
   of the request.", required: true
  param :verification_code, String, :desc => 'authentication code for password reset',
    :required => true
  param :password, String, :desc => 'new password'
  param :password_confirmation, String, :desc => 'new password confirmation'
  formats ['JSON']
  error 404, 'doesn\'t request for reset password first'
  error 401, 'verification code doesn\'t match'
  error 401, 'unauthorized, account not found'
  error 400, 'parameter missing'
  error 412, 'account not activate'
  error 422, 'parameter value error'
  def reset_password
    unless params && params[:verification_code]
      return render_params_missing_error
    else
      code = current_student.verification_code
      # error handler
      return render_error(I18n.t('students.errors.verification_code.missing'),
                          :not_found) if code.nil?
      return render_error(I18n.t('students.errors.verification_code.invalid'),
                          :unauthorized) if !code.to_i.eql?(params[:verification_code].to_i)
      if params[:password] && params[:password_confirmation]
        # update the password
        password_params = params.permit(:password, :password_confirmation)
        return save_model_error current_student unless current_student.\
          update_attributes(password_params)
        current_student.clear_verification_code
        # return success message
        render_message(I18n.t 'students.reset_password.success')
      else
        render_message(I18n.t 'students.reset_password.verification')
      end
    end
  end

  # Student request to send a new verification_code for account activation and
  # password reset
  api :GET, '/students/send_verification_code', '[(step 1) for resetting the
    password] request to send a new verification_code for account activation
    and password reset'
  header 'Authorization', "authentication token has to be passed as part
   of the request.", required: true
  error 401, 'unauthorized, account not found'
  error 412, 'account not activate'
  def send_verification_code
    current_student.send_verification_sms
    render_message(I18n.t 'students.send_verification_code.success')
  end

  # Student signout
  api :DELETE, '/students/signout', 'signout students, clean the device token'
  header 'Authorization', "authentication token has to be passed as part
   of the request.", required: true
  error 401, 'unauthorized, account not found'
  error 412, 'account not activate'
  def destroy
    # clear the device token
    if current_student.update_attribute(:device_token, nil)
      render_message(I18n.t 'students.destroy.success')
    else
      save_model_error current_student
    end
  end

  api :POST, '/students/rate', 'student rates the appointment'
  header 'Authorization', "authentication token has to be passed as part
    of the request.", required: true
  param :appointment_id, Integer, :desc => 'appointment id'
  param :rate, Integer, :desc => 'scale from 1 to 10, 1 is the lowest'
  param :feedback, String, :desc => 'student gives feedback to the tutor'
  error 401, 'unauthorized, account not found'
  error 412, 'account not activate'
  error 400, 'parameter missing' 
  error 422, 'parameter value error'
  def rate
    if params && params[:appointment_id] && params[:rate] && params[:feedback]
      ap = current_student.appointments.find(params[:appointment_id])

      if ap && ap.update_attributes(:student_feedback => params[:feedback],
                                    :student_rating => params[:rate])
        render_message(I18n.t 'students.rate.success')
      else
        save_model_error(ap)
      end
    else
      return render_params_missing_error
    end
  end

  api :POST, '/students/appointments', 'retrieve all appointments of the student,
    retrieve the specific appointment if we pass the appointment id.'
  header 'Authorization', "authentication token has to be passed as part
    of the request.", required: true 
  param :appointment_id, Integer, :desc => 'appointment id'
  error 401, 'unauthorized, account not found'
  error 412, 'account not activate'
  error 422, 'parameter value error'
  def appointments
    if params && params[:appointment_id]
      # Return the appointment according to appointment id
      ap = current_student.appointments.find_by_id(params[:appointment_id])
      if ap
        render json: ap, :status => :ok
      else
        # Invalid appointment id
        render_error(I18n.t('students.errors.appointment.invalid_id'),
                     :unprocessable_entity)
      end
    else
      # Return all the appointments
      aps = ActiveModelSerializers::SerializableResource
            .new(current_student.appointments,
                each_serializer: Core::AppointmentSerializer)
            .as_json
      render json: aps, :status => :ok
    end
  end

################################################################################ 
# Following code Need to be updated
################################################################################ 

  # Get the number of tutors online
  def tutors_online_count
    if params && params[:plan_id]
      c = Core::Tutor.where(["state = ? and level >= ?", "available", params[:plan_id]]).count
      render :json => {:message => "#{c}"}, :status => 200
    else
      json_error_message 400, (I18n.t 'error.messages.parameters')
    end
  end


  private

  # (Updated) Only get the require information for student register
  def student_signup_params
    params[:student][:balance] = 0
    params[:student][:state] = 'offline'
    params.require(:student).permit(:name, :password, :email, :gender,
                                    :password_confirmation, :balance,
                                    :phoneNumber, :picture, :country_code,
                                    :state)
  end

  # (Updated) Only get the required information for the tutor editing
  def student_edit_params
    params.require(:student).permit(:email, :name, :device_token, 
                                    :picture, :gender)
  end

  def tutor_state_params
    params.require(:tutor).permit(:id)
  end

  # Define the require params for edit the appointment for student
  def rate_feedback_params
    params.require(:appointment).permit(:id, :student_rating, :student_feedback)
  end

  # Define the require params for edit the appointment for student
  def rate_feedback_set_prioritized_tutor_params
    params.permit(:set_prioritized_tutor)
  end

  # Only get the required information for the set prioritized tutor
  def student_set_prioritized_tutor_params
    params.require(:student).permit(:prioritized_tutor)
  end

  # Only get the required information for the request get tutor
  def request_get_tutor_params
    params.require(:request).permit(:id)
  end

  # Only get the required information for the request cancel look for tutors
  def request_cancel_look_for_tutors_params
    params.permit(:session_id)
  end

  # (updated) Check whether the student account has been activated or not
  def activation_check
    if !current_student.activated?
      render :json => {:error => I18n.t('students.errors.activation')},
             :status => :precondition_failed
    end
  end

  # (updated) Authenticate the student accourding to the auth_token in the header
  def authenticate_student_request
    @current_student = AuthorizeApiRequest.call('student', request.headers).result
    render :json => {:error => I18n.t('students.errors.credential')},
           :status => :unauthorized unless @current_student
  end
end