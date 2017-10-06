require 'rails_helper'

RSpec.describe MakeCallJob, type: :job do
  include ActiveJob::TestHelper

  let(:appointment) { create(:appointment) }
  subject(:job) { MakeCallJob.perform_later(appointment.student_id,
                                            appointment.tutor_id,
                                            appointment.id) }

  it 'executes perform' do
    expect(ActionCable.server).to receive(:broadcast).\
      with("student_#{appointment.student_id}", any_args)
    expect(ActionCable.server).to receive(:broadcast).\
      with("tutor_#{appointment.tutor_id}", any_args)
    perform_enqueued_jobs { job }
    appointment.reload
    expect(appointment.conference_name).not_to be_nil
  end

  after do
    # Complete the conference room
    account_sid = Settings.Twilio.account_sid
    auth_token  = Settings.Twilio.auth_token
    client = Twilio::REST::Client.new(account_sid, auth_token)
    client.video.rooms(appointment.conference_name)
                .update(status: 'completed')
                # Clean the job
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
