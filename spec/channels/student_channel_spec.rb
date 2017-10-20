require 'rails_helper'
require_relative 'stubs/test_connection'

RSpec.describe StudentChannel, type: :channel do

  before do
    @student      = create(:student)
    @connection   = TestConnection.new(@student)
    @channel      = StudentChannel.new @connection, {}
    @action_cable = ActionCable.server
  end

  let(:request_data) do
    {
      "action"    => "request",
      "plan_id"   => 1,
      "tutor_id"  => 1
    }
  end

  let(:cancel_data) do
    {
      "action"    => "cancel"
    }
  end

  it "broadcasts request successfully" do
    # add tutor to tutor online queue
    TutorOnlineQueue.instance.push(1)
    @channel.perform_action(request_data)
    expect(MessageBroadcastJob).to have_been_enqueued.with(
      { student_id: @student.id, plan_id: request_data['plan_id'] },
      'comming_request', tutor_id: request_data['tutor_id'])
    expect(@student.state).to eql('requesting')
  end

  it "fails with request because tutor is not available" do
    @channel.perform_action(request_data)
    expect(MessageBroadcastJob).to have_been_enqueued.with(
      I18n.t('students.errors.appointment.busy'), 'error',
      student_id: @student.id)
    expect(@student.state).to eql('online')
  end

  it "cancels request successfully" do
    # change the student state to request
    @student.change_state('requesting')
    @channel.perform_action(cancel_data)
    @student.reload
    expect(@student.state).to eql('online')
  end

  it "fails to cancel the request" do
    # change the student state to online
    @student.change_state('online')
    @channel.perform_action(cancel_data)
    expect(MessageBroadcastJob).to have_been_enqueued.with(
      I18n.t('students.errors.appointment.cancel'), 'error',
      student_id: @student.id
    )
  end
end