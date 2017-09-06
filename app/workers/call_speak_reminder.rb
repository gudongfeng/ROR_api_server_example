class CallSpeakReminder< ActionController::Base
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def init
    @AUTH_ID = Settings.Plivo.auth_id
    @AUTH_TOKEN = Settings.Plivo.auth_token
  end

  def perform call_uuid
    init
    p = RestAPI.new(@AUTH_ID, @AUTH_TOKEN)
    params = {
        'call_uuid' => call_uuid,
        'text' => 'your call will end in 1 minutes'
    }
    p.speak(params)
  end

end