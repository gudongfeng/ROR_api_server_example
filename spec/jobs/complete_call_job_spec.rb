require 'rails_helper'

RSpec.describe CompleteCallJob, type: :job do
  include ActiveJob::TestHelper

  let(:appointment) { create(:appointment) }
  subject(:job) { CompleteCallJob.perform_later(appointment.id) }

  it 'completes an appointment' do
    expect{ job }.to have_enqueued_job.on_queue("conference")
    expect(CompleteCallJob).to have_been_enqueued.with(appointment.id)
  end

  it 'executes perform' do
    # Create a conference room at the beignning
    account_sid = Settings.Twilio.account_sid
    auth_token  = Settings.Twilio.auth_token
    client = Twilio::REST::Client.new(account_sid, auth_token)
    room_name = (0...50).map { ('a'..'z').to_a[rand(26)] }.join
    room = client.video.rooms.create(unique_name: room_name)
    room_sid = room.sid
    appointment.update_attribute(:conference_name, room_sid)
    # Check the student and tutor notification
    expect(ActionCable.server).to receive(:broadcast).\
      with("student_#{appointment.student_id}", any_args)
    expect(ActionCable.server).to receive(:broadcast).\
      with("tutor_#{appointment.tutor_id}", any_args)
    # Perform the job
    perform_enqueued_jobs { job }
    # Check the room state again
    room = client.video.rooms(room_sid).fetch()
    expect(room.status).to eq('completed')
  end
  
  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
