require 'rails_helper'

RSpec.describe Core::Appointment, type: :model do
  let(:appointment) { create(:appointment) }

  describe '#Create' do
    it 'sucesses with factorygirl' do
      expect(appointment).to be_valid
    end

    it 'success' do
      student = create(:student)
      tutor   = create(:tutor)
      Core::Appointment.create({ start_time: Time.now,
                                 end_time: Time.now + 10.minutes,
                                 student_rating: 5,
                                 tutor_rating: 10,
                                 student_feedback: 'test feedback',
                                 tutor_feedback: 'test feedback',
                                 plan_id: 3,
                                 tutor_earned: 10.00,
                                 amount: 10.00,
                                 student_id: student.id,
                                 tutor_id: tutor.id})
      expect(Core::Appointment.first).to be_valid
    end

    it 'fails with missing start_time and end_time' do
      appointment = build(:appointment)
      appointment.start_time = nil
      appointment.end_time = nil
      appointment.save
      expect(appointment.errors.details[:start_time]).to \
        include({:error => :blank})
      expect(appointment.errors.details[:end_time]).to \
        include({:error => :blank})
      expect(appointment).to_not be_valid
    end

    it 'fails with invalid student_rating' do
      appointment = build(:appointment)
      appointment.student_rating = 0
      appointment.save
      expect(appointment.errors.details[:student_rating]).to \
        include({:error => :inclusion, :value => 0})
    end

    it 'fails with invalid tutor_rating' do
      appointment = build(:appointment)
      appointment.tutor_rating = 0
      appointment.save
      expect(appointment.errors.details[:tutor_rating]).to \
        include({:error => :inclusion, :value => 0})
    end

    it 'fails with invalid plan_id' do
      appointment = build(:appointment)
      appointment.plan_id = 0
      appointment.save
      expect(appointment.errors.details[:plan_id]).to \
        include({:error => :inclusion, :value => 0})
    end
  end

end