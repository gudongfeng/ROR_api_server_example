require 'rails_helper'

RSpec.describe TutorMessageBroadcastJob, type: :job do
  include ActiveJob::TestHelper

  let(:tutor) { create(:tutor) }
  subject(:job) { TutorMessageBroadcastJob.perform_later(
    tutor.id, 'comming_request', { plan_id: 1, student_id: 1 }) }

  it 'broadcasts request to tutor' do
    expect{ job }.to have_enqueued_job.on_queue("tutor_message")
    expect(TutorMessageBroadcastJob).to have_been_enqueued.with(
      tutor.id, 'comming_request', { plan_id: 1, student_id: 1 })
  end

  it 'executes perform' do
    expect(ActionCable.server).to receive(:broadcast).\
      with("tutor_#{tutor.id}", any_args)
    perform_enqueued_jobs { job }
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
