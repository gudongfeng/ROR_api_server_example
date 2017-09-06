require 'rails_helper'

RSpec.describe AuthenticationController, type: :controller do
  describe 'POST #authenticate_student' do
    before do
      @student = create(:student)
    end

    it 'with valid information' do
      post :authenticate_student, params: { phone: @student.phoneNumber,
                                            password: 123456 }
      expect(response).to have_http_status(:ok)
    end

    it 'with invalid information' do
      post :authenticate_student, params: { phone: 12345,
                                            password: 91827329 }
      expect(response).to have_http_status(:unauthorized)
    end

    it 'fail with missing parameters' do
      post :authenticate_student
      expect(response).to have_http_status(:bad_request)
      expect(json['error']).to eq(I18n.t 'api.errors.parameters')
    end
  end


  describe 'POST #authenticate_tutor' do
    before do
      @tutor = create(:tutor)
    end

    it 'with valid information' do
      post :authenticate_tutor, params: { phone: @tutor.phoneNumber,
                                          password: 123456 }
      expect(response).to have_http_status(:ok)
    end

    it 'with invalid information' do
      post :authenticate_tutor, params: { phone: 12345,
                                          password: 91827329 }
      expect(response).to have_http_status(:unauthorized)
    end

    it 'fail with missing parameters' do
      post :authenticate_tutor
      expect(response).to have_http_status(:bad_request)
      expect(json['error']).to eq(I18n.t 'api.errors.parameters')
    end
  end

end