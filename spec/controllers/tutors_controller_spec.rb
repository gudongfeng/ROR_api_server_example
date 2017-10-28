require 'rails_helper'

RSpec.describe Api::V1::TutorsController, type: :controller do

  before do |example|
    unless example.metadata[:skip_token]
      @token = AuthenticateTutor.call(tutor.phoneNumber,
                                      tutor.password).result
      # add the authenticate header to the request
      add_authenticate_header @token
      unless example.metadata[:skip_activation]
        tutor.activate
      end
    end
  end

  describe 'Get #show' do
    let(:tutor) { create(:tutor_with_education) }

    it 'returns single tutor', :show_in_doc do
      get :show
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq(Core::TutorSerializer.new(tutor).to_json)
    end
  end

  describe 'POST #create', :skip_token do
    it 'creates a tutor', :show_in_doc do
      post :create, params: { 
                      tutor: { 
                        email: 'test@test.com',
                        name: 'tutor',
                        phoneNumber: '88888888',
                        password: '123456',
                        password_confirmation: '123456',
                        country_code: 86,
                        picture: 'http://picture.url',
                        gender: 'male',
                        education: { a: { school: 'abc school',
                                          major: 'computer science',
                                          degree: 'bachelor',
                                          start_time: Time.now,
                                          end_time: Time.now },
                                     b: { school: 'cde school',
                                          major: 'computer science',
                                          degree: 'master',
                                          start_time: Time.now,
                                          end_time: Time.now } }
                      } 
                    }
      expect(response).to have_http_status(:ok)
      expect(json['message']).to eq(I18n.t 'tutors.create.success')
      expect(Core::Tutor.find_by(email: 'test@test.com').educations.count).to eq(2)
    end

    it 'fail with missing parameters' do
      post :create, params: { 'fake': 'fake' }
      expect(response).to have_http_status(:bad_request)
    end

    it 'fails with invalid tutor general information' do
      post :create, params: { 
                      tutor: { 
                        email: 'test@test.com',
                        name: 'tutor',
                        phoneNumber: 'invalidphonenumber',
                        password: '123456',
                        password_confirmation: '123456',
                        country_code: 'invalid',
                        picture: 'http://picture.url',
                        gender: 'invalid',
                        education: { school: 'abc school' } 
                      } 
                    }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json['error']).to include('gender', 'country_code', 'phoneNumber')
    end

    it 'fails with invalid education information' do
      post :create, params: { 
                      tutor: { 
                        email: 'test@test.com',
                        name: 'tutor',
                        phoneNumber: '88888888',
                        password: '123456',
                        password_confirmation: '123456',
                        country_code: 86,
                        picture: 'http://picture.url',
                        gender: 'male',
                        education: { a: { major: 'computer science',
                                          degree: 'bachelor',
                                          start_time: Time.now,
                                          end_time: Time.now } }
                      } 
                    }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json['error']).to include('school')
    end
  end

  describe 'POST #activate_account' do
    let(:tutor) { create(:tutor) }

    it 'successes', :show_in_doc, :skip_activation do
      post :activate_account, params: { verification_code:
                                          tutor.verification_code}
      tutor.reload
      expect(tutor.activated).to eq true
      expect(response).to have_http_status(:ok)
      expect(json['message']).to eq (I18n.t 'tutors.activate_account.success')
    end
  end
  
  describe 'PATCH #edit' do
    let(:tutor) { create(:tutor_with_education) }

    it 'edits the tutor information', :show_in_doc do
      # patch to edit the tutor device token information
      patch :edit, params: { tutor: { device_token: 'test_token',
                                      education: { 
                                        a: { id: tutor.educations.first,
                                             school: 'abc school',
                                             major: 'computer science',
                                             degree: 'bachelor',
                                             start_time: Time.now,
                                             end_time: Time.now },
                                        b: { school: 'cde school',
                                             major: 'computer science',
                                             degree: 'bachelor',
                                             start_time: Time.now,
                                             end_time: Time.now }
                                      } } }
      tutor.reload
      expect(tutor.device_token).to eq('test_token')
      expect(response).to have_http_status(:ok)
      expect(json['message']).to eq(I18n.t('tutors.edit.success'))
      expect(tutor.educations.count).to eq 2
      expect(tutor.educations.first.school).to eq('abc school')
      expect(tutor.educations.second.school).to eq('cde school')
    end
    
    it 'add a new education', :show_in_doc do
      # patch to add a new education
      patch :edit, params: { tutor: { education: {
                                      a: { school: 'abc school',
                                           major: 'computer science',
                                           degree: 'bachelor',
                                           start_time: Time.now,
                                           end_time: Time.now } } } } 
      tutor.reload
      expect(tutor.educations.count).to eq 2
      expect(json['message']).to eq(I18n.t('tutors.edit.success'))
      expect(tutor.educations.second.school).to eq('abc school')
    end

    it 'fails with missing parameters' do
      patch :edit, params: { phoneNumber: 'asldfkj' }
      expect(response).to have_http_status(:bad_request)
    end

    it 'fails with invalid parameter values' do
      # patch with invalid infos
      patch :edit, params: { tutor: { phoneNumber: 'invalid_phoneNumber',
                                      gender: 'invalid_gender' } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json['error']).to include('gender', 'phoneNumber')
    end

    it 'fails with unactivated account', :skip_activation do
      patch :edit
      expect(response).to have_http_status(:precondition_failed)
      expect(json['error']).to eq(I18n.t('tutors.errors.activation'))
    end
  end

  describe 'DELETE #destroy' do
    let(:tutor) { create(:tutor_with_education) }

    it 'delete a tutor', :show_in_doc do
      delete :destroy
      expect(response).to have_http_status(:ok)
      expect(json['message']).to eq(I18n.t('tutors.destroy.success'))
      tutor.reload
      expect(tutor.device_token).to eq nil
    end
  end

  describe 'GET #send_verification_code' do
    let(:tutor) { create(:tutor) }

    it 'success', :show_in_doc do
      get :send_verification_code
      expect(response).to have_http_status :ok
      expect(json['message']).to eq I18n.t('tutors.send_verification_code.success')
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

  describe 'POST #reset_password' do
    let(:tutor) { create(:tutor) }

    it 'successfully verifiy verification code', :show_in_doc do
      # create a new verification_code for this tutor
      tutor.verification_code = 1234
      tutor.save
      post :reset_password, params: { verification_code: tutor.verification_code }
      expect(response).to have_http_status :ok
      expect(json['message']).to eq(I18n.t('tutors.reset_password.verification'))
    end
    
    it 'reset the password', :show_in_doc do
      # create a new verification code for this tutor
      tutor.verification_code = 1234
      tutor.save
      post :reset_password, params: { verification_code: tutor.verification_code,
                                      password: 'new_pass',
                                      password_confirmation: 'new_pass' }
      expect(response).to have_http_status :ok
      expect(json['message']).to eq(I18n.t 'tutors.reset_password.success')
    end
    
    
    it 'fail with empty verification_code' do
      tutor.verification_code = nil
      tutor.save
      post :reset_password, params: { verification_code: tutor.verification_code, 
                                      password: 'new_pass',
                                      password_confirmation: 'new_pass' }
      expect(response).to have_http_status :not_found
      expect(json['error']).to eq I18n.t('tutors.errors.verification_code.missing')
    end

    it 'fails with invalid verification_code' do
      # create a new verification_code for this tutor
      tutor.verification_code = 1234
      tutor.save
      post :reset_password, params: { verification_code: '7361' }
      expect(response).to have_http_status :unauthorized
      expect(json['error']).to eq I18n.t('tutors.errors.verification_code.invalid')
    end

    it 'fails with missing parameter' do
      post :reset_password
      expect(response).to have_http_status :bad_request
    end
  end

  describe 'POST #rate' do
    let(:appointment) { create(:appointment) }
    let(:tutor) { appointment.tutor }

    it 'rate the appointment successfully', :show_in_doc do
      post :rate, params: { appointment_id: appointment.id, rate: 10, feedback: 'good' }
      expect(response).to have_http_status :ok
      appointment.reload
      expect(appointment.tutor_rating).to eql(10)
      expect(appointment.tutor_feedback).to eql('good')
    end
    
    it 'rate the appointment with invalid parameters' do
      post :rate, params: { appointment_id: appointment.id, rate: 11, feedback: 'good' }
      expect(response).to have_http_status :unprocessable_entity
      expect(json['error']).to include('tutor_rating')
    end
    
    it 'fails with missing parameters' do
      post :rate, params: { appointment_id: appointment.id, rate: 1 }
      expect(response).to have_http_status(:bad_request)
    end
  end


  describe 'POST #appointments' do
    let(:appointment) { create(:appointment) }
    let(:tutor) { appointment.tutor }

    it 'get all the appointment information of the tutor', :show_in_doc do
      post :appointments
      expect(response).to have_http_status :ok
      expect(response.body).to eq \
        ActiveModelSerializers::SerializableResource
          .new(tutor.appointments, each_serializer: Core::AppointmentSerializer)
          .to_json
    end

    it 'get one appointment information of the tutor', :show_in_doc do
      post :appointments, params: { appointment_id: appointment.id }
      expect(response).to have_http_status :ok
      expect(response.body).to eq Core::AppointmentSerializer.new(appointment).to_json
    end

    it 'return error when give the invalid id of appointments' do
      post :appointments, params: { appointment_id: 1000 }
      expect(response).to have_http_status :unprocessable_entity
      expect(json['error']).to eq I18n.t('tutors.errors.appointment.invalid_id')
    end
  end
end
