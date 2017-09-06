class NotifyCallEndJob < ApplicationJob
  queue_as :conference

  def perform()
    # TODO: notify both tutor and student that the call will end in several mins
    # 
  end
end
