require 'rails_helper'

RSpec.describe "Tutor request", :type => :request do
  let(:tutor) { create(:tutor) }

  before do
    # Authenticate the Tutor
    post authenticate_tutor_path, params: { phone: tutor.phoneNumber,
                                            password: tutor.password }
    @token = json['auth_token']
  end

  describe 'create a tutor' do
    it 'success' do
      post api_v1_tutors_signup_path, params: {
        'tutor': {
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
    end
  end

  describe 'show a tutor information' do
    it 'success' do
      headers = { Authorization: @token }
      # Activate the tutor account first
      tutor.activate
      get api_v1_tutors_info_path, headers: headers
      expect(response.body).to eq(Core::TutorSerializer.new(tutor).to_json)
    end
  end

  describe 'edit the tutor information' do
    it 'success' do
      headers = { Authorization: @token}
      tutor.activate
      patch '/api/v1/tutors/info',
        params: { tutor: { device_token: 'test_token',
                                      education: { 
                                        a: { school: 'abc school',
                                             major: 'computer science',
                                             degree: 'bachelor',
                                             start_time: Time.now,
                                             end_time: Time.now } 
                                      } } },
        headers: headers
      expect(response).to have_http_status(:ok)
      expect(json['message']).to eq I18n.t('tutors.edit.success')
    end
  end
end