require 'rails_helper'

RSpec.describe Api::V1::StudentsController, type: :controller do

  before do |example|
    unless example.metadata[:skip_token]
      @token = AuthenticateStudent.call(student.phoneNumber,
                                        student.password).result
      add_authenticate_header @token
      unless example.metadata[:skip_activation]
        student.activate
      end
    end
  end

  describe 'GET #show' do
    let(:student) { create(:student) }

    before do |example|
      unless example.metadata[:skip_token]
        @token = AuthenticateStudent.call(student.phoneNumber,
                                          student.password).result
        add_authenticate_header @token
      end
    end

    it 'returns single student', :show_in_doc do
      get :show
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq (Core::StudentSerializer.new(student).to_json)
    end
  end

  describe 'POST #create' do
    it 'creates a student', :show_in_doc, :skip_token do
      post :create, params: { 
                      'student': { 
                        name: 'testName', 
                        phoneNumber: '88888888',
                        password: 'testPassword',
                        password_confirmation: 'testPassword',
                        picture: 'http://fakeURL',
                        gender: 'male',
                        country_code: 86
                      } 
                    }
      expect(response).to have_http_status(:ok)
      expect(json['message']).to eq(I18n.t 'students.create.success')
      expect(Core::Student.all.count).to eq 1
    end

    it 'fails with missing params', :show_in_doc, :skip_token do
      post :create, params: { 'fake': 'fake' }
      expect(response).to have_http_status(:bad_request)
    end

    it 'fails with invalid params', :show_in_doc, :skip_token do
      post :create, params: { 
                      'student': {
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

  describe 'POST #activate_account' do
    let(:student) { create(:student) }
  
    it 'successes', :show_in_doc, :skip_activation do
      post :activate_account, params: { verification_code:
                                          student.verification_code }
      student.reload
      expect(student.activated).to eq true
      expect(response).to have_http_status(:ok)
      expect(json['message']).to eq (I18n.t 'students.activate_account.success')
    end

    it 'fails with invalid code', :show_in_doc, :skip_activation do
      post :activate_account, params: { verification_code:
                                          '123' }
      student.reload
      expect(student.activated).to eq false
      expect(response).to have_http_status(:unauthorized)
      expect(json['error']).to eq (I18n.t 'students.errors.verification_code.invalid')
    end
  end

  describe 'PATCH #edit' do
    let(:student) { create(:student) }
    
    it 'success', :show_in_doc do
      expect(student.device_token).to eq nil
      patch :edit, params: { student: { device_token: 'test_token' } }
      student.reload
      expect(student.device_token).to eq('test_token')
      expect(response).to have_http_status(:ok)
      expect(json['message']).to eq(I18n.t('students.edit.success'))
    end

    it 'fails with invalid parameter values' do
      patch :edit, params: { student: { email: 'invalid_email',
                                        gender: 'invalid_gender' } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json['error']).to include('gender', 'email')
    end

    it 'fails with unactivated account', :skip_activation do
      patch :edit
      expect(response).to have_http_status(:precondition_failed)
      expect(json['error']).to eq(I18n.t('students.errors.activation'))
    end
  end

  describe 'POST #reset_password' do
    let(:student) { create(:student) }

    it 'successfully verifiy verification code', :show_in_doc do
      # create a new verification_code for this student
      student.verification_code = 1234
      student.save
      post :reset_password, params: { verification_code: student.\
        verification_code }
      expect(response).to have_http_status :ok
      expect(json['message']).to eq I18n.t('students.reset_password.verification')
    end

    it 'success with password parameter', :show_in_doc do
      # create a new verification_code for this student
      student.verification_code = 1234
      student.save
      post :reset_password, params: { verification_code: student.\
        verification_code, password: 'new_pass' , password_confirmation:
        'new_pass' }
      expect(response).to have_http_status :ok
      expect(json['message']).to eq I18n.t('students.reset_password.success')
    end

    it 'fail with empty verification_code' do
      post :reset_password, params: { verification_code: student.\
        verification_code, password: 'new_pass' , password_confirmation:
        'new_pass' }
      expect(response).to have_http_status :not_found
      expect(json['error']).to eq I18n.t('students.errors.verification_code.missing')
    end

    it 'fails with invalid verification_code' do
      # create a new verification_code for this student
      student.verification_code = 1234
      student.save
      post :reset_password, params: { verification_code: '7361', 
                                      password: 'new_pass' , 
                                      password_confirmation: 'new_pass' }
      expect(response).to have_http_status :unauthorized
      expect(json['error']).to eq I18n.t('students.errors.verification_code.invalid')
    end

    it 'fails with missing parameter' do
      post :reset_password
      expect(response).to have_http_status :bad_request
    end
  end

  describe 'GET #send_verification_code' do
    let(:student) { create(:student) }

    it 'success', :show_in_doc do
      get :send_verification_code
      expect(response).to have_http_status :ok
      expect(json['message']).to eq I18n.t('students.send_verification_code.success')
    end

    it 'fail with invalid header information', :skip_token do
      get :send_verification_code
      expect(response).to have_http_status :unauthorized
    end

    it 'fail with inactivate account', :skip_activation do
      get :send_verification_code
      expect(response).to have_http_status :precondition_failed
    end
  end

  describe 'DELETE #destroy' do
    let(:student) { create(:student) }

    it 'delete a tutor', :show_in_doc do
      delete :destroy
      expect(response).to have_http_status(:ok)
      expect(json['message']).to eq(I18n.t('students.destroy.success'))
      student.reload
      expect(student.device_token).to eq nil
    end
  end

  describe 'POST #rate' do
    let(:appointment) { create(:appointment) }
    let(:student) { appointment.student }

    it 'rate the appointment successfully', :show_in_doc do
      post :rate, params: { appointment_id: appointment.id, rate: 10, feedback: 'good' }
      expect(response).to have_http_status :ok
      appointment.reload
      expect(appointment.student_rating).to eql(10)
      expect(appointment.student_feedback).to eql('good')
    end
    
    it 'rate the appointment with invalid parameters' do
      post :rate, params: { appointment_id: appointment.id, rate: 11, feedback: 'good' }
      expect(response).to have_http_status :unprocessable_entity
      expect(json['error']).to include('student_rating')
    end
    
    it 'fails with missing parameters' do
      post :rate, params: { appointment_id: appointment.id, rate: 1 }
      expect(response).to have_http_status(:bad_request)
    end
  end
end
