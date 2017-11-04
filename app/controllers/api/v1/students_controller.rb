# frozen_string_literal: true

module Api
  module V1
    # Student controller
    class StudentsController < ApiController
      prepend_before_action :authenticate_student_request,
                            only: %i[show edit reset_password get_status rate
                                     send_verification_code destroy
                                     activate_account appointments]
      before_action :activation_check,
                    only: %i[show edit reset_password get_status
                             send_verification_code destroy rate appointments]

      attr_reader :current_student

      # Student sign up function
      api :POST, '/students/signup', 'student sign up'
      param :student, Hash, desc: 'student parameters' do
        param :name, String, desc: 'student name', required: true
        param :phoneNumber, String,
              desc: 'student phone number', required: true
        param :password, String, desc: 'password', required: true
        param :password_confirmation, String,
              desc: 'confirmation of password', required: true
        param :country_code, [86, 1],
              desc: '86/1 China/America & anada', required: true
        param :gender, %w[male female], required: true
        param :picture, String, desc: 'picture url'
      end
      formats ['JSON']
      error 400, 'parameter missing'
      error 403, 'invalid parameter'
      error 422, 'parameter value error'
      def create
        params_arr = %i[password phoneNumber country_code name gender
                        password_confirmation]
        return render_params_missing_error unless params?(params_arr, 'student')
        # Create a new student
        student = Core::Student.new(student_signup_params)
        return save_model_error(student) unless student.save
        # Send the verification code sms to the student
        student.send_verification_sms
        render(json: { message: I18n.t('students.create.success'),
                       student_id: student.id }, status: :ok)
      end

      # Activate student account according to the verification code
      api :POST, '/students/activate_account', 'activate student'
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
        return unless code_valid?(current_student.verification_code)
        # activate the account
        current_student.activate
        render_message(I18n.t('students.activate_account.success'))
      end

      # Edit the student information
      api :PATCH, '/students/info', 'edit the student information'
      param :student, Hash, desc: 'student parameters' do
        param :name, String, desc: 'student name'
        param :email, String, desc: 'student email'
        param :device_token, String, desc: 'device token'
        param :picture, String, desc: 'student picture url'
        param :gender, %w[male female], desc: 'student gender'
      end
      header 'Authorization', 'authentication token has to be passed as part
        of the request.', required: true
      error 400, 'parameter missing'
      error 401, 'unauthorized, account not found'
      error 412, 'account not activate'
      error 422, 'parameter value error'
      def edit
        return render_params_missing_error unless params?([:student])
        return save_model_error(current_student) unless
          current_student.update_attributes(student_edit_params)
        render_message(I18n.t('students.edit.success'))
      end

      # Get student information
      api :GET, '/students/info', 'get the information of a single student'
      header 'Authorization', 'authentication token has to be passed as part
        of the request.', required: true
      error 401, 'unauthorized, account not found'
      error 412, 'account not activate'
      def show
        render(json: current_student, status: :ok)
      end

      # Update the password once the verification process has done
      api :POST, '/students/reset_password', '[(step 2,3) for resetting the
        password], you need to call send_verification_code first to send an sms
        message to student, verify the verification code only if password and
        password confirmation absent'
      header 'Authorization', 'authentication token has to be passed as part
        of the request.', required: true
      param :verification_code, String,
            desc: 'authentication code for password reset', required: true
      param :password, String, desc: 'new password'
      param :password_confirmation, String, desc: 'new password confirmation'
      formats ['JSON']
      error 404, 'should request for reset password first'
      error 401, 'verification code doesn\'t match'
      error 401, 'unauthorized, account not found'
      error 400, 'parameter missing'
      error 412, 'account not activate'
      error 422, 'parameter value error'
      def reset_password
        return render_params_missing_error unless params?([:verification_code])
        # Check the validation of the code
        return unless code_valid?(current_student.verification_code)
        unless params?(%i[password password_confirmation])
          return render_message(I18n.t('students.reset_password.verification'))
        end
        # Update the password
        password_params = params.permit(:password, :password_confirmation)
        return save_model_error(current_student) unless
          current_student.update_attributes(password_params)
        current_student.clear_verification_code
        # Return success message
        render_message(I18n.t('students.reset_password.success'))
      end

      # Student request to send a new verification_code for account activation
      # and password reset
      api :GET, '/students/send_verification_code', '[(step 1) for resetting the
        password] request to send a new verification_code for account activation
        and password reset'
      header 'Authorization', 'authentication token has to be passed as part
        of the request.', required: true
      error 401, 'unauthorized, account not found'
      error 412, 'account not activate'
      def send_verification_code
        current_student.send_verification_sms
        render_message(I18n.t('students.send_verification_code.success'))
      end

      # Student signout
      api :DELETE, '/students/signout', 'signout students, clean device token'
      header 'Authorization', 'authentication token has to be passed as part
        of the request.', required: true
      error 401, 'unauthorized, account not found'
      error 412, 'account not activate'
      def destroy
        # clear the device token
        return save_model_error(current_student) unless
          current_student.update_attribute(:device_token, nil)
        render_message(I18n.t('students.destroy.success'))
      end

      api :POST, '/students/rate', 'student rates the appointment'
      header 'Authorization', 'authentication token has to be passed as part
        of the request.', required: true
      param :appointment_id, Integer, desc: 'appointment id'
      param :rate, Integer, desc: 'scale from 1 to 10, 1 is the lowest'
      param :feedback, String, desc: 'student gives feedback to the tutor'
      error 401, 'unauthorized, account not found'
      error 412, 'account not activate'
      error 400, 'parameter missing'
      error 422, 'parameter value error'
      def rate
        return render_params_missing_error unless
          params?(%i[appointment_id rate feedback])
        ap = current_student.appointments.find(params[:appointment_id])
        result = ap.update_attributes(student_feedback: params[:feedback],
                                      student_rating: params[:rate])
        return render_message(I18n.t('students.rate.success')) if result
        save_model_error(ap)
      end

      api :POST, '/students/appointments', 'retrieve all appointments of the
        student, retrieve the specific appointment if we pass the appointment
        id.'
      header 'Authorization', 'authentication token has to be passed as part
        of the request.', required: true
      param :appointment_id, Integer, desc: 'appointment id'
      error 401, 'unauthorized, account not found'
      error 412, 'account not activate'
      error 422, 'parameter value error'
      def appointments
        if params?([:appointment_id])
          # Return the appointment according to appointment id
          ap = current_student.appointments.find_by(id: params[:appointment_id])
          return render(json: ap, status: :ok) if ap
          # Invalid appointment id
          render_error(I18n.t('students.errors.appointment.invalid_id'),
                       :unprocessable_entity)
        else
          # Return all the appointments
          aps = ActiveModelSerializers::SerializableResource
                .new(current_student.appointments).as_json
          render(json: aps, status: :ok)
        end
      end

      private

      # Only get the require information for student register
      def student_signup_params
        params[:student][:balance] = 0
        params[:student][:state] = 'offline'
        params.require(:student).permit(:name, :password, :email, :gender,
                                        :password_confirmation, :balance,
                                        :phoneNumber, :picture, :country_code,
                                        :state)
      end

      # Only get the required information for the tutor editing
      def student_edit_params
        params.require(:student).permit(:email, :name, :device_token,
                                        :picture, :gender)
      end

      # Check whether the student account has been activated or not
      def activation_check
        return if current_student.activated?
        render(json: { error: I18n.t('students.errors.activation') },
               status: :precondition_failed)
      end

      # Authenticate the student accourding to the auth_token in the
      # header
      def authenticate_student_request
        @current_student = AuthorizeApiRequest.call('student', request.headers)
                                              .result
        return if @current_student
        render(json: { error: I18n.t('students.errors.credential') },
               status: :unauthorized)
      end
    end
  end
end
