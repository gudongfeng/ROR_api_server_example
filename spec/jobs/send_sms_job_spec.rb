require 'rails_helper'

RSpec.describe SendSmsJob, type: :job do
  let(:student) { create(:student) }
  subject(:job) { SendSmsJob.perform_later(student.phoneNumber,
                                           student.country_code,
                                           student.verification_code)}
  it 'enqueues another awesome job' do
    expect{ job }.to have_enqueued_job.on_queue("default")
    expect(SendSmsJob).to have_been_enqueued.with(student.phoneNumber,
      student.country_code,student.verification_code)
  end
end
