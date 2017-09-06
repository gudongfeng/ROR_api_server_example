require 'rails_helper'

RSpec.describe Core::Student, type: :model do
  let(:student) { create(:student) }

  describe '#Create' do
    it 'sucesses' do
      expect(student).to be_valid
    end

    it 'fails with invalid phone' do
      student.phoneNumber = 'invalid'
      student.save
      
      expect(student.errors.details[:phoneNumber]).to \
        include({:error => :invalid, :value => "invalid"})
      expect(student).to_not be_valid
    end

    it 'fails with invalid email' do
      student.email = 'invalid'
      student.save
      expect(student.errors.details[:email]).to \
        include({:error => :invalid, :value => 'invalid'})
    end

    it 'fails with invalid country_code' do
      student.country_code = 2
      student.save
      expect(student.errors.details[:country_code]).to \
        include({:error => :inclusion, :value => 2})
    end

    it 'fails with invalid gender' do
      student.gender = 'invalid'
      student.save
      expect(student.errors.details[:gender]).to \
        include({:error => :inclusion, :value => 'invalid'})
    end

    it 'fails with invalid state' do
      student.state = 'invalid'
      student.save
      expect(student.errors.details[:state]).to \
        include({ :error => :inclusion, :value => 'invalid'})
    end
  end

  describe '#Function' do
    it 'send the verification sms successfully' do
      student.phoneNumber = '6138549198'
      student.save
      student.send_verification_sms
      expect {
        student.send_verification_sms
      }.to have_enqueued_job(SendSmsJob)
    end
  end
end