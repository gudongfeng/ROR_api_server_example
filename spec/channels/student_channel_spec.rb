require 'rails_helper'
require_relative 'stubs/test_connection'

RSpec.describe StudentChannel, type: :channel do

  before do
    @student = create(:student)
    @connection = TestConnection.new(@student)
    @channel = StudentChannel.new @connection, {}
    @action_cable = ActionCable.server
  end

  let(:data) do
    {
      "action"    => "request",
      "plan_id"   => 1,
      "tutor_id"  => 1
    }
  end

  it "broadcasts request successfully" do
    # add tutor to tutor online queue
    TutorOnlineQueue.instance.push(1)
    @channel.perform_action(data)
    expect(MessageBroadcastJob).to have_been_enqueued.with(
      { student_id: @student.id, plan_id: data['plan_id'] },
      'comming_request', tutor_id: data['tutor_id'])
  end

  it "fails because tutor is not available" do
    @channel.perform_action(data)
    expect(MessageBroadcastJob).to have_been_enqueued.with(
      I18n.t('students.errors.appointment.busy'), 'error',
      student_id: @student.id)
  end
end