require 'rails_helper'

RSpec.describe MakeCallJob, type: :job do
  include ActiveJob::TestHelper

  let(:student) { create(:student) }
  let(:tutor) { create(:tutor) }

  subject(:job) { MakeCallJob.perform_later(student.id, tutor.id) }

  it 'create a call' do
    expect{ job }.to have_enqueued_job.on_queue("conference")
    expect(MakeCallJob).to have_been_enqueued.with(
      student.id, tutor.id
    )
  end

  it 'executes perform' do
    expect(ActionCable.server).to receive(:broadcast).\
      with("student_#{student.id}", any_args)
    expect(ActionCable.server).to receive(:broadcast).\
      with("tutor_#{tutor.id}", any_args)
    perform_enqueued_jobs { job }
  end


end
