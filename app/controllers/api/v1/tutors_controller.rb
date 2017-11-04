# frozen_string_literal: true

module Api
  module V1
    # Tutor controller
    class TutorsController < ApiController
      prepend_before_action :authenticate_tutor_request,
                            only: %i[show edit get_status destroy reset_password
                                     send_verification_code activate_account
                                     rate appointments]
      before_action :activation_check,
                    only: %i[show edit get_status destroy reset_password
                             send_verification_code rate appointments]
      attr_reader :current_tutor
      # Get tutor information
      api :GET, '/tutors/info', 'get the information of a single tutor'
      header 'Authorization', 'authentication token has to be passed as part
        of the request.', required: true
      error 401, 'unauthorized, account not found'
      error 412, 'account not activate'
      def show
        render(json: current_tutor, status: :ok)
      end

      # Tutor sign up
      api :POST, '/tutors/signup', 'tutor sign up'
      param :tutor, Hash, desc: 'tutor parameters' do
        param :name, String, desc: 'tutor name', required: true
        param :email, String, desc: 'tutor email', required: true
        param :phoneNumber, String, desc: 'tutor phone number', required: true
        param :password, String, desc: 'password', required: true
        param :password_confirmation, String, desc: 'confirmation of password',
                                              required: true
        param :country_code, [86, 1], desc: '86/1 China/America & Canada',
                                      required: true
        param :gender, %w[male female], required: true
        param :picture, String, desc: 'picture url'
        param :country, String, desc: 'tutor country location'
        param :region, String, desc: 'tutor region'
        param :description, String, desc: 'tutor description'
        param :education, Hash, desc: 'all the education information' do
          param :char, String, desc: 'single education information' do
            param :school, String, desc: 'school name'
            param :major, String, desc: 'education major'
            param :degree, %w[associate bachelor master doctoral]
            param :start_time, nil, desc: 'start time for this education'
            param :end_time, nil, desc: 'end time for this education'
          end
        end
      end
      formats ['JSON']
      error 400, 'parameter missing'
      error 403, 'invalid parameter'
      error 422, 'parameter value error'
      def create
        params_arr = %i[email password password_confirmation name phoneNumber
                        country_code gender]
        return render_params_missing_error unless params?(params_arr, 'tutor')
        # Create a new tutor
        tutor = Core::Tutor.new(tutor_signup_params)
        return save_model_error(tutor) unless tutor.save
        # Add each education information for this tutor
        errors = update_educations(tutor, params[:tutor][:education])
        return render_error(errors, :unprocessable_entity) unless errors.nil?
        # send the verification sms code to the tutor
        tutor.send_verification_sms
        render(json: { message: I18n.t('tutors.create.success'),
                       tutor_id: tutor.id }, status: :ok)
      end

      # Activate tutor account
      api :POST, '/tutors/activate_account', 'activate tutor account'
      param :verification_code, String,
            desc: 'verification code', required: true
      header 'Authorization', 'authentication token has to be passed as part
        of the request.', required: true
      formats ['JSON']
      error 400, 'parameter missing'
      error 401, 'unauthorized, account not found'
      error 401, 'verification code is wrong'
      def activate_account
        return render_params_missing_error unless params?([:verification_code])
        return unless code_valid?(current_tutor.verification_code)
        # activate tutor account
        current_tutor.activate
        render_message(I18n.t('tutors.activate_account.success'))
      end

      # Edit the Tutor Information
      api :PATCH, '/tutors/info', 'edit the tutor information'
      param :tutor, Hash, desc: 'tutor parameters' do
        param :name, String, desc: 'tutor name'
        param :phoneNumber, String, desc: 'tutor phone number'
        param :gender, %w[male female]
        param :picture, String, desc: 'picture url'
        param :description, String, desc: 'tutor description'
        param :region, String, desc: 'tutor region'
        param :country_code, [86, 1], desc: '86/1 China/America & Canada'
        param :level, [1, 2, 3], desc: '1 means the lowest level'
        param :country, String, desc: 'tutor country location'
        param :device_token, String, desc: 'tutor device token'
        param :education, Hash, desc: 'add/or edit the education information' do
          param :char, String, desc: 'single education information' do
            param :id, Integer, required: true, desc: 'education id'
            param :school, String, desc: 'school name'
            param :major, String, desc: 'education major'
            param :degree, %w[associate bachelor master doctoral]
            param :start_time, nil, desc: 'start time for this education'
            param :end_time, nil, desc: 'end time for this education'
          end
        end
      end
      header 'Authorization', 'authentication token has to be passed as part
        of the request.', required: true
      error 400, 'parameter missing'
      error 401, 'unauthorized, account not found'
      error 412, 'account not activate'
      error 422, 'parameter value error'
      def edit
        return render_params_missing_error unless params?([:tutor])
        return save_model_error current_tutor unless
          current_tutor.update_attributes(tutor_general_edit_params)
        # Update the tutor education information if client pass the tutor
        # education info
        if params?([:education], 'tutor')
          # Add each education information for this tutor
          errors = update_educations(current_tutor, params[:tutor][:education])
          return render_error(errors, :unprocessable_entity) unless errors.nil?
        end
        render_message(I18n.t('tutors.edit.success'))
      end

      # Update the password once the verification process has done
      api :POST, '/tutors/reset_password', '[(step 2,3) for resetting the
        password], you need to call send_verification_code first to send an
        sms message to tutor, verify the verification code only if password
        and password confirmation absent'
      header 'Authorization', 'authentication token has to be passed as part
       of the request.', required: true
      param :verification_code, String,
            desc: 'authentication code for password reset', required: true
      param :password, String, desc: 'new password'
      param :password_confirmation, String, desc: 'new password confirmation'
      formats ['JSON']
      error 404, 'doesn\'t request for reset password first'
      error 401, 'verification code doesn\'t match'
      error 401, 'unauthorized, account not found'
      error 400, 'parameter missing'
      error 412, 'account not activate'
      error 422, 'parameter value error'
      def reset_password
        return render_params_missing_error unless params?([:verification_code])
        return unless code_valid?(current_tutor.verification_code)
        unless params?(%i[password password_confirmation])
          return render_message(I18n.t('tutors.reset_password.verification'))
        end
        # Update the password
        password_params = params.permit(:password, :password_confirmation)
        return save_model_error current_tutor unless
          current_tutor.update_attributes(password_params)
        current_tutor.clear_verification_code
        render_message(I18n.t('tutors.reset_password.success'))
      end

      # Tutor request to send a new verification_code for account activation and
      # password reset
      api :GET, '/tutors/send_verification_code', '[(step 1) for resetting the
        password] request to send a new verification_code for account activation
        and password reset'
      header 'Authorization', 'authentication token has to be passed as part
       of the request.', required: true
      error 401, 'unauthorized, account not found'
      error 412, 'account not activate'
      def send_verification_code
        current_tutor.send_verification_sms
        render_message(I18n.t('tutors.send_verification_code.success'))
      end

      api :DELETE, '/tutors/signout', 'signout the tutor, clean the device token'
      header 'Authorization', 'authentication token has to be passed as part
       of the request.', required: true
      error 401, 'unauthorized, account not found'
      error 412, 'account not activate'
      def destroy
        # clear the device token
        return save_model_error(current_tutor) unless
          current_tutor.update_attribute(:device_token, nil)
        render_message(I18n.t('tutors.destroy.success'))
      end

      api :POST, '/tutors/rate', 'tutor rates the appointment'
      header 'Authorization', 'authentication token has to be passed as part
        of the request.', required: true
      param :appointment_id, Integer, desc: 'appointment id'
      param :rate, Integer, desc: 'scale from 1 to 10, 1 is the lowest'
      param :feedback, String, desc: 'tutor give feedback to this student'
      error 401, 'unauthorized, account not found'
      error 412, 'account not activate'
      error 400, 'parameter missing'
      error 422, 'parameter value error'
      def rate
        return render_params_missing_error unless
          params?(%i[appointment_id rate feedback])
        ap = current_tutor.appointments.find(params[:appointment_id])
        result = ap.update_attributes(tutor_feedback: params[:feedback],
                                      tutor_rating: params[:rate])
        return render_message(I18n.t('tutors.rate.success')) if result
        save_model_error(ap)
      end

      api :POST, '/tutors/appointments', 'retrieve all appointments of the tutor,
        retrieve the specific appointment if we pass the appointment id.'
      header 'Authorization', 'authentication token has to be passed as part
        of the request.', required: true
      param :appointment_id, Integer, desc: 'appointment id'
      error 401, 'unauthorized, account not found'
      error 412, 'account not activate'
      error 422, 'parameter value error'
      def appointments
        if params?([:appointment_id])
          # Return the appointment according to appointment id
          ap = current_tutor.appointments.find_by(id: params[:appointment_id])
          return render(json: ap, status: :ok) if ap
          # Invalid appointment id
          render_error(I18n.t('students.errors.appointment.invalid_id'),
                       :unprocessable_entity)
        else
          # Return all the appointments
          aps = ActiveModelSerializers::SerializableResource
                .new(current_tutor.appointments).as_json
          render(json: aps, status: :ok)
        end
      end

      private

      # Only get the required information for tutor registration
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

      def tutor_education_params(education_info)
        education_info.permit(:id, :school, :major, :degree, :start_time, :end_time)
      end

      # Only get the required information for the tutor editing
      def tutor_general_edit_params
        params.require(:tutor).permit(:name, :phoneNumber, :gender, :picture,
                                      :device_type, :description, :region,
                                      :country_code, :level, :country, :device_token)
      end

      # Create/Update the tutor education information
      def update_educations(tutor, educations)
        # Save the educations information
        error_str = nil
        educations.each do |_key, value|
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
          next if success
          error_str = I18n.t 'term.error'
          error_str += ' : '
          # Grab the error message from the tutor
          education.errors.each do |attr, msg|
            error_str += "#{attr} - #{msg},"
          end
        end
        error_str
      end

      # Tutor account activation check
      def activation_check
        return if current_tutor.activated?
        render(json: { error: I18n.t('tutors.errors.activation') },
               status: :precondition_failed)
      end

      # Authenticate the tutor according to the auth_token in the header
      def authenticate_tutor_request
        @current_tutor = AuthorizeApiRequest.call('tutor', request.headers)
                                            .result
        return if @current_tutor
        render(json: { error: I18n.t('tutors.errors.credential') },
               status: :unauthorized)
      end
    end
  end
end
