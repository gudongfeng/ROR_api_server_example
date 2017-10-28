class Api::V1::TutorsController < Api::ApiController
  prepend_before_action :authenticate_tutor_request,
    :only => [:show, :edit, :get_status, :destroy, :reset_password,
              :send_verification_code, :activate_account, :rate,
              :appointments]
  before_action :activation_check,
    :only => [:show, :edit, :get_status, :destroy, :reset_password,
              :send_verification_code, :rate, :appointments]

  attr_reader :current_tutor

  # Get tutor information
  api :GET, '/tutors/info', 'get the information of a single tutor'
  header 'Authorization', "authentication token has to be passed as part
    of the request.", required: true
  error 401, 'unauthorized, account not found'
  error 412, 'account not activate'
  def show
    render json: current_tutor, :status => :ok
  end

  # Tutor sign up
  api :POST, '/tutors/signup', 'tutor sign up'
  param :tutor, Hash, :desc => 'tutor parameters' do
    param :name, String, :desc => 'tutor name', :required => true
    param :email, String, :desc => 'tutor email', :required => true
    param :phoneNumber, String, :desc => 'tutor phone number', :required => true
    param :password, String, :desc => 'password', :required => true
    param :password_confirmation, String, :desc => 'confirmation of password',
          :required => true
    param :country_code, [86, 1], :desc => '86/1 China/America & Canada',
          :required => true
    param :gender, ['male', 'female'], :required => true
    param :picture, String, :desc => 'picture url'
    param :country, String, :desc => 'tutor country location'
    param :region, String, :desc => 'tutor region'
    param :description, String, :desc => 'tutor description'
    param :education, Hash, :desc => 'all the education information' do
      param :char, String, :desc => 'single education information' do
        param :school, String, :desc => 'school name'
        param :major, String, :desc => 'education major'
        param :degree, ['associate', 'bachelor', 'master', 'doctoral']
        param :start_time, nil, :desc => 'start time for this education'
        param :end_time, nil, :desc => 'end time for this education'
      end
    end
  end
  formats ['JSON']
  error 400, 'parameter missing'
  error 403, 'invalid parameter'
  error 422, 'parameter value error'
  def create
    if params && params[:tutor] && params[:tutor][:email] &&
        params[:tutor][:password] && params[:tutor][:password_confirmation] &&
        params[:tutor][:name] && params[:tutor][:phoneNumber] &&
        params[:tutor][:country_code] && params[:tutor][:gender]
      # Create a new tutor
      tutor = Core::Tutor.new(tutor_signup_params)
      return save_model_error tutor unless tutor.save
      # Add each education information for this tutor
      educations = params[:tutor][:education]
      errors = update_educations(tutor, educations)
      if errors.nil?
        # used to send an activation email to user / disabled for demo purpose
        #@tutor.send_activation_email
        #@tutor.activate
        
        # send the verification sms code to the tutor
        tutor.send_verification_sms
        render_message(I18n.t 'tutors.create.success')
      else
        return render_error(errors, :unprocessable_entity) 
      end
    else
      return render_params_missing_error
    end
  end
  
  # Activate tutor account
  api :POST, '/tutors/activate_account', 'activate tutor account'
  param :verification_code, String, :desc => "verification code", required: true
  header 'Authorization', "authentication token has to be passed as part
    of the request.", required: true
  formats ['JSON']
  error 400, 'parameter missing'
  error 401, 'unauthorized, account not found'
  error 401, 'verification code is wrong'
  def activate_account
    if params && params[:verification_code]
      code = current_tutor.verification_code
      # code missing error
      return render_error(I18n.t('tutor.errors.verification_code.missing'),
                          :not_found) if code.nil?
      # code doesn't match
      return render_error(I18n.t('tutors.errors.verification_code.invalid'), 
                          :unauthorized) if !code.to_i.eql? params[:verification_code].to_i
      # activate tutor account
      current_tutor.activate
      render_message(I18n.t 'tutors.activate_account.success')
    else
      return render_params_missing_error
    end
  end

  # Edit the Tutor Information
  api :PATCH, '/tutors/info', 'edit the tutor information'
  param :tutor, Hash, :desc => 'tutor parameters' do
    param :name, String, :desc => 'tutor name'
    param :phoneNumber, String, :desc => 'tutor phone number'
    param :gender, ['male', 'female']
    param :picture, String, :desc => 'picture url'
    param :description, String, :desc => 'tutor description'
    param :region, String, :desc => 'tutor region'
    param :country_code, [86, 1], :desc => '86/1 China/America & Canada'
    param :level, [1, 2, 3], :desc => '1 means the lowest level'
    param :country, String, :desc => 'tutor country location'
    param :device_token, String, :desc => 'tutor device token'
    param :education, Hash, :desc => 'add/or edit the education information' do
      param :char, String, :desc => 'single education information' do
        param :id, Integer, :required => true, :desc => 'education id'
        param :school, String, :desc => 'school name'
        param :major, String, :desc => 'education major'
        param :degree, ['associate', 'bachelor', 'master', 'doctoral']
        param :start_time, nil, :desc => 'start time for this education'
        param :end_time, nil, :desc => 'end time for this education'
      end
    end
  end
  header 'Authorization', "authentication token has to be passed as part
    of the request.", required: true
  error 400, 'parameter missing'
  error 401, 'unauthorized, account not found'
  error 412, 'account not activate'
  error 422, 'parameter value error'
  def edit
    if params && params[:tutor]
      return save_model_error current_tutor unless
        current_tutor.update_attributes(tutor_general_edit_params)
      # Update the tutor education information if client pass the tutor 
      # education info
      if params[:tutor][:education]
        # Add each education information for this tutor
        educations = params[:tutor][:education]
        errors = update_educations(current_tutor, educations)
        return render_error(errors, :unprocessable_entity) if !errors.nil?
      end
      render_message(I18n.t 'tutors.edit.success')
    else
      return render_params_missing_error
    end
  end

  # Update the password once the verification process has done
  api :POST, '/tutors/reset_password', '[(step 2,3) for resetting the password],
    you need to call send_verification_code first to send an sms message to tutor,
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
    if params && params[:verification_code]
      code = current_tutor.verification_code
      # return error if code is nil
      return render_error(I18n.t('tutors.errors.verification_code.missing'),
                          :not_found) if code.nil?
      # return error if code doesn't match
      return render_error(I18n.t('tutors.errors.verification_code.invalid'),
                          :unauthorized) if !code.to_i.eql?(params[:verification_code].to_i)
      if params[:password] && params[:password_confirmation]
        # update the password
        password_params = params.permit(:password, :password_confirmation)
        return save_model_error current_tutor unless current_tutor.\
          update_attributes(password_params)
        current_tutor.clear_verification_code
        render_message(I18n.t 'tutors.reset_password.success')
      else
        render_message(I18n.t 'tutors.reset_password.verification')
      end
    else
      return render_params_missing_error
    end
  end

  # Tutor request to send a new verification_code for account activation and password reset
  api :GET, '/tutors/send_verification_code', '[(step 1) for resetting the
    password] request to send a new verification_code for account activation
    and password reset'
  header 'Authorization', "authentication token has to be passed as part
   of the request.", required: true
  error 401, 'unauthorized, account not found'
  error 412, 'account not activate'
  def send_verification_code
    current_tutor.send_verification_sms
    render_message(I18n.t 'tutors.send_verification_code.success')
  end

  api :DELETE, '/tutors/signout', 'signout the tutor, clean the device token'
  header 'Authorization', "authentication token has to be passed as part
   of the request.", required: true
  error 401, 'unauthorized, account not found'
  error 412, 'account not activate'
  def destroy
    # clear the device token
    if current_tutor.update_attribute(:device_token, nil)
      render_message(I18n.t 'tutors.destroy.success')
    else
      save_model_error current_tutor
    end
  end

  api :POST, '/tutors/rate', 'tutor rates the appointment'
  header 'Authorization', "authentication token has to be passed as part
    of the request.", required: true
  param :appointment_id, Integer, :desc => 'appointment id'
  param :rate, Integer, :desc => 'scale from 1 to 10, 1 is the lowest'
  param :feedback, String, :desc => 'tutor give feedback to this student'
  error 401, 'unauthorized, account not found'
  error 412, 'account not activate'
  error 400, 'parameter missing' 
  error 422, 'parameter value error'
  def rate
    if params && params[:appointment_id] && params[:rate] && params[:feedback]
      ap = current_tutor.appointments.find(params[:appointment_id])

      if ap && ap.update_attributes(:tutor_feedback => params[:feedback],
                                    :tutor_rating => params[:rate])
        render_message(I18n.t 'tutors.rate.success')
      else
        save_model_error(ap)
      end
    else
      return render_params_missing_error
    end
  end


  api :POST, '/tutors/appointments', 'retrieve all appointments of the tutor,
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
      ap = current_tutor.appointments.find_by_id(params[:appointment_id])
      if ap
        render json: ap, :status => :ok
      else
        # Invalid appointment id
        render_error(I18n.t('tutors.errors.appointment.invalid_id'),
                    :unprocessable_entity)
      end
    else
      # Return all the appointments
      aps = ActiveModelSerializers::SerializableResource
            .new(current_tutor.appointments,
                each_serializer: Core::AppointmentSerializer)
            .as_json
      render json: aps, :status => :ok
    end
  end


################################################################################ 
# Following code Need to be updated
################################################################################ 


  # Get the number of tutors online
  def online_count
    c = Core::Tutor.where.not(remember_token: nil).count
    render :json => {:message => "#{c}"}, :status => 200
  end

  # Check if the currently logged user has valid token
  def verify_token
    render :json => {:message => (I18n.t 'success.messages.login_token')},
           :status => 200
  end



  # Request to get the info of the pending student
  def request_get_student
    if params
      if @tutor && @tutor.remember_expiry > Time.now
        rv = @tutor.requests.find_by_id(tutor_request_get_student_params[:id])
        if rv
          render :json => rv.student.to_json, :status => 200
        else
          json_error_message 404, (I18n.t 'error.messages.no_record')
        end
      else
        json_error_message 401, (I18n.t 'error.messages.login')
      end
    else
      json_error_message 400, (I18n.t 'error.messages.parameters')
    end
  end

  # Request to accept or decline the student
  def request_reply
    if params
      if @tutor && @tutor.remember_expiry > Time.now
        if @tutor.request_reply(tutor_request_reply_params[:id],
                                tutor_request_reply_params[:reply])
          render :json => {:message => (I18n.t 'success.messages.reply')},
                 :status => 200
        else
          json_error_message 400, (I18n.t 'error.messages.reply')
        end
      else
        json_error_message 401, (I18n.t 'error.messages.login')
      end
    else
      json_error_message 400, (I18n.t 'error.messages.parameters')
    end
  end

  # Check if the tutor's email has been regist or not
  def check_email
    if params
      if Core::Tutor.find_by(email: params[:email])
        render :json => {:message => 'false'}, :status => 200
      else
        render :json => {:message => 'true'}, :status => 200
      end
    else
      json_error_message 400, (I18n.t 'error.messages.parameters')
    end
  end

  private

  # (updated) Only get the required information for tutor registration
  def tutor_signup_params
    # Initialize the tutor balance value
    params[:tutor][:balance] = 0
    # Initial tutor level is the lowest level
    params[:tutor][:level] = 1
    params.require(:tutor).permit(:name, :email, :password, :gender, :picture,
                                  :password_confirmation, :balance,
                                  :phoneNumber, :description, :region,
                                  :country_code, :level, :country)
  end

  # (updated)
  def tutor_education_params(education_info)
    education_info.permit(:id, :school, :major, :degree, :start_time, :end_time)
  end

  # (updated) Only get the required information for the tutor editing
  def tutor_general_edit_params
    params.require(:tutor).permit(:name, :phoneNumber, :gender, :picture,
                                  :device_type, :description, :region, 
                                  :country_code, :level, :country, :device_token)
  end

  # Define the require params for edit the appointment for tutor
  def tutor_rate_feedback_params
    params.require(:appointment).permit(:id, :tutor_rating, :tutor_feedback)
  end

  # Only get the required information for the tutor change state
  def tutor_change_state_params
    params.require(:tutor).permit(:state)
  end

  # Only get the required information for the request get student
  def tutor_request_get_student_params
    params.require(:request).permit(:id)
  end

  # Only get the required information for the request reply
  def tutor_request_reply_params
    params.require(:request).permit(:id, :reply)
  end

  # (updated) Create/Update the tutor education information
  def update_educations(tutor, educations)
    # Save the educations information
    error_str = nil
    educations.each do |key, value|
      success = nil
      if tutor_education_params(value)[:id]
        # Try to find the existing education record
        education = Core::Education.find(tutor_education_params(value)[:id])
        success = education.update_attributes(tutor_education_params(value))
      else
        # Create a new education record
        education = tutor.educations.new(tutor_education_params(value))
        success = education.save
      end
      # Write the error
      if !success
        error_str = I18n.t 'term.error'
        error_str += ' : '
        # Grab the error message from the tutor
        education.errors.each do |attr,msg|
          error_str += "#{attr} - #{msg},"
        end 
      end
    end
    return error_str
  end

  # (update) Tutor account activation check
  def activation_check
    if !current_tutor.activated?
      render :json => {:error => I18n.t('tutors.errors.activation')},
             :status => :precondition_failed
    end
  end

  # (updated) Authenticate the tutor according to the auth_token in the header
  def authenticate_tutor_request
    @current_tutor = AuthorizeApiRequest.call('tutor', request.headers).result
    render :json => {:error => I18n.t('tutors.errors.credential')},
           :status => :unauthorized unless @current_tutor
  end
end
