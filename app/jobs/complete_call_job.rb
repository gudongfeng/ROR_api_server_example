class CompleteCallJob < ApplicationJob
  queue_as :conference

  def perform()
    # TODO: terminate the conference room using the twilio api
    # TODO: notifiy both student and tutor that the conference room terminated
  end
end
