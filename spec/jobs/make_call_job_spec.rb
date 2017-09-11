require 'rails_helper'

RSpec.describe MakeCallJob, type: :job do
  include ActiveJob::TestHelper

  let(:appointment) { create(:appointment) }
  subject(:job) { MakeCallJob.perform_later(appointment.student_id,
                                            appointment.tutor_id,
                                            appointment.id) }

  it 'create a call' do
    expect{ job }.to have_enqueued_job.on_queue("conference")
    expect(MakeCallJob).to have_been_enqueued.with(
      appointment.student_id, appointment.tutor_id, appointment.id
    )
  end

  it 'executes perform' do
    expect(ActionCable.server).to receive(:broadcast).\
      with("student_#{appointment.student_id}", any_args)
    expect(ActionCable.server).to receive(:broadcast).\
      with("tutor_#{appointment.tutor_id}", any_args)
    perform_enqueued_jobs { job }
    appointment.reload
    expect(appointment.conference_name).not_to be_nil
  end


end
