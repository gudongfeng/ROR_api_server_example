require 'rails_helper'

RSpec.describe StudentMessageBroadcastJob, type: :job do
  include ActiveJob::TestHelper

  let(:student) { create(:student) }
  subject(:job) { StudentMessageBroadcastJob.perform_later(
                    student.id, 'regular', { message: 'test message' })}

  it 'send notification to a student' do
    expect{ job }.to have_enqueued_job.on_queue("student_message")
    expect(StudentMessageBroadcastJob).to have_been_enqueued.with(
      student.id, 'regular',  { message: 'test message' }
    )
  end

  it 'executes perform' do
    expect(ActionCable.server).to receive(:broadcast).\
      with("student_#{student.id}", any_args)
    perform_enqueued_jobs { job }
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
