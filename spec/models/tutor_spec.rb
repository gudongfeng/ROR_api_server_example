require 'rails_helper'

RSpec.describe Core::Tutor, type: :model do
  let(:tutor) { create(:tutor) }

  describe '#Create' do
    it 'success' do
      expect(tutor).to be_valid
    end

    it 'fails with invalid email info' do
      tutor.email = nil
      tutor.save

      expect(tutor.errors.details[:email]).to include(
        {:error => :blank}
      )
      expect(tutor).to_not be_valid
    end

    it 'fails with invalid phoneNumber property' do
      tutor.phoneNumber = 'invalid'
      tutor.save
      
      expect(tutor.errors.details[:phoneNumber]).to include(
        {:error => :invalid, :value => "invalid"}
      )
    end

    it 'fails with invalid country_code' do
      tutor.country_code = 'invalid'
      tutor.save
      
      expect(tutor.errors.details[:country_code]).to include(
        {:error => :inclusion, :value => 0}
      )
    end

    it 'fails with invalid gender' do
      tutor.gender = 'invalid'
      tutor.save
      expect(tutor.errors.details[:gender]).to include(
        {:error => :inclusion, :value => 'invalid'}
      )
    end

  end

  describe '#Function' do
    it 'send the verification sms successfully' do
      tutor.phoneNumber = '6138549198'
      tutor.save
      expect { tutor.send_verification_sms }.to \
        have_enqueued_job(SendSmsJob)
    end
  end
end