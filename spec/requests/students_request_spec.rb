require 'rails_helper'

RSpec.describe "Student request", :type => :request do

  before do |example|
    unless example.metadata[:skip_token]
      # Authenticate the Student
      post authenticate_student_path, params: { phone: student.phoneNumber,
                                                password: student.password }
      @token = json['auth_token']
      unless example.metadata[:skip_activation]
        student.activate
      end
    end
  end

  describe 'create the student', :skip_token do
    it 'successes' do
      post api_v1_students_signup_path, 
          params: { 'student': 
                      { name: 'testName', 
                        phoneNumber: '88888888',
                        password: 'testPassword',
                        password_confirmation: 'testPassword',
                        picture: 'http://fakeURL',
                        gender: 'male',
                        country_code: 86 }
                  }
      expect(response).to have_http_status(:ok)
      expect(json['message']).to eq(I18n.t 'students.create.success')
    end

    it 'fails with missing params' do
      post api_v1_students_signup_path, params: { 'fake': 'fake' }
      expect(response).to have_http_status(:bad_request)
    end

    it 'fails with invalid params' do
      post api_v1_students_signup_path, 
          params: { 'student': 
                      {
                        name: 'testName', 
                        phoneNumber: 'qweoiru',
                        password: 'testPassword',
                        password_confirmation: 'testPassword',
                        picture: 'http://fakeURL',
                        gender: 'maleasdf',
                        country_code: '71263'
                      } 
                  }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json['error']).to include 'gender', 'country_code', 'phoneNumber'
    end
  end

  describe 'show the student information' do
    let(:student) { create(:student) }

    it 'successed', :skip_activation do
      headers = { Authorization: @token }
      # activate the student first
      post api_v1_students_activate_account_path,
          params: { verification_code: student.verification_code },
          headers: headers
      get api_v1_students_info_path, headers: headers
      expect(response.body).to eq(Core::StudentSerializer.new(student).to_json)
    end

    it 'failed with invalid token' do
      get api_v1_students_info_path
      expect(response).to have_http_status(:unauthorized)
      expect(json['error']).to eq(I18n.t('students.errors.credential'))
    end
  end

  describe 'activate student account', :skip_activation do
    let(:student) { create(:student) }

    it 'successed' do
      headers = { Authorization: @token }
      post api_v1_students_activate_account_path, 
          params: { verification_code: student.verification_code },
          headers: headers
      expect(response).to have_http_status(:ok)
      expect(json['message']).to eq(I18n.t('students.activate_account.success'))
    end

    it 'failed with invalid verification code' do
      headers = { Authorization: @token }
      post api_v1_students_activate_account_path, 
          params: { verification_code: 1234 },
          headers: headers
      expect(response).to have_http_status(:unauthorized)
      expect(json['error']).to eq(I18n.t('students.errors.verification_code.invalid'))
    end
  end

  describe 'edit the student information' do
    let(:student) { create(:student) }

    it 'successes' do
      headers = { Authorization: @token }
      patch '/api/v1/students/info',
          params: { student: { device_token: 'valid_token' } },
          headers: headers
      expect(response).to have_http_status(:ok)
      expect(json['message']).to eq I18n.t('students.edit.success')
    end

    it 'fails with missing parameters' do
      headers = { Authorization: @token }
      patch '/api/v1/students/info',
          headers: headers
      expect(response).to have_http_status(:bad_request)
      expect(json['error']).to eq I18n.t('api.errors.parameters')
    end

    it 'fails with inactive account', :skip_activation do
      headers = { Authorization: @token }
      patch '/api/v1/students/info',
          headers: headers
      expect(response).to have_http_status(:precondition_failed)
      expect(json['error']).to eq I18n.t('students.errors.activation')
    end

    it 'fails with invalid auth token', :skip_token do
      patch '/api/v1/students/info'
      expect(response).to have_http_status(:unauthorized)
      expect(json['error']).to eq I18n.t('students.errors.credential')
    end

    it 'fails with invalid state value' do
      headers = { Authorization: @token }
      patch '/api/v1/students/info',
          params: { student: { state: 'invalide_state' } },
          headers: headers
      expect(response).to have_http_status :unprocessable_entity
      expect(json['error']).to include 'state'
    end
  end

  describe 'reset the password' do
    let(:student) { create(:student) }

    it 'success' do
      headers = { Authorization: @token }
      # create a new verification code
      student.verification_code = 1234
      student.save
      post api_v1_students_reset_password_path, params: { 
        verification_code: 1234,
        password: 'new_pass',
        password_confirmation: 'new_pass' },
        headers: headers
      expect(response).to have_http_status :ok
      expect(json['message']).to eq I18n.t('students.reset_password.success')
    end

    it 'fail with invalid password confirmation' do
      headers = { Authorization: @token }
      # create a new verification code
      student.verification_code = 1234
      student.save
      post api_v1_students_reset_password_path, params: { 
        verification_code: 1234,
        password: 'new_pass',
        password_confirmation: 'invalid_pass' },
        headers: headers
      expect(response).to have_http_status :unprocessable_entity
      expect(json['error']).to include 'password_confirmation'
    end

    it 'fail with missing or invalid authorization headers', :skip_token do
      post api_v1_students_reset_password_path
      expect(response).to have_http_status :unauthorized
      expect(json['error']).to eq I18n.t('students.errors.credential')
    end
  end

  describe 'request to reset the password' do
    let(:student) { create(:student) }

    it 'success' do
      headers = { Authorization: @token }
      expect {
        get api_v1_students_send_verification_code_path, headers: headers
      }.to have_enqueued_job(SendSmsJob)
      expect(response).to have_http_status :ok
    end
  end

  describe 'get the student status' do
    let(:student) { create(:student) }

    it 'success' do
      headers = { Authorization: @token }
      get api_v1_students_status_path, headers: headers
      expect(response).to have_http_status :ok
      expect(json).to eq student.get_current_status.as_json
    end
  end
end