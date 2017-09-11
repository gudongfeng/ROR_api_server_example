require 'rails_helper'
require_relative 'stubs/test_connection'

RSpec.describe TutorChannel, type: :channel do
  
  before do
    @tutor = create(:tutor)
    @connection = TestConnection.new(@tutor)
    @channel = TutorChannel.new @connection, {}
    @action_cable = ActionCable.server
  end

  let(:student) { create(:student) }
  let(:data) do
    {
      "action"    => "response",
      "response"  => "accept",
      "message"   => { "plan_id"   => 1,
                       "student_id"=> student.id }
    }
  end

  it "accepts a request" do
    @channel.perform_action(data)
    expect(Core::Appointment.count).to eq 1
  end

  it "decline a request" do
    data['response'] = 'decline'
    @channel.perform_action(data)
    @tutor.reload
    expect(@tutor.decline_count).to eq 1
  end

  it "does not response" do
    data['response'] = nil
    @channel.perform_action(data)
    @tutor.reload
    expect(@tutor.decline_count).to eq 1
  end
end