class TutorGoOffline < ActionController::Base
  include Sidekiq::Worker

  def perform tutor_id
    tutor = Core::Tutor.find tutor_id
    # change the tutor state to unavailable when tutor is available
    tutor.change_state 'unavailable' if tutor.state.eql? 'available'
    # clear the job id
    tutor.update_attribute :tutor_timer_job_id, nil
  end
end
