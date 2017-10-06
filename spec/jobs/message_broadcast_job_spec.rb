require 'rails_helper'

RSpec.describe MessageBroadcastJob, type: :job do
  include ActiveJob::TestHelper

  let(:student) { create(:student) }
  let(:tutor) { create(:tutor) }
  subject(:job) { MessageBroadcastJob.perform_later(
                    { message: 'test message' }, 'notification',
                    student_id = student.id, tutor_id = tutor.id) }

  it 'send notification to student and tutor' do
    expect{ job }.to have_enqueued_job.on_queue("message")
    expect(MessageBroadcastJob).to have_been_enqueued.with(
      { message: 'test message' }, 'notification', 
      student_id = student.id, tutor_id = tutor.id
    )
  end

  it 'executes perform' do
    expect(ActionCable.server).to receive(:broadcast)
      .with("student_#{student.id}", any_args)
    expect(ActionCable.server).to receive(:broadcast)
      .with("tutor_#{tutor.id}", any_args)
    perform_enqueued_jobs { job }
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
