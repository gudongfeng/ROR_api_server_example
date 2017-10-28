require 'sidekiq/web'
# ...
Rails.application.routes.draw do
  
  # Serve websocket cable requests in-process
  mount ActionCable.server => '/cable'
  
  # API document
  apipie

  # Welcome pages
  root 'application#hello'
  
  # Main function
  namespace :api do
    namespace :v1 do
      # student info
      # (updated)
      get   'students/info'    => 'students#show'
      patch 'students/info'    => 'students#edit'
      post  'students/rate'    => 'students#rate'
      post  'students/signup'  => 'students#create'
      delete'students/signout' => 'students#destroy'
      post  'students/appointments'     => 'students#appointments'
      post  'students/activate_account' => 'students#activate_account'
      post  'students/reset_password'   => 'students#reset_password'
      get   'students/send_verification_code' => 'students#send_verification_code'

      # teacher info
      # (updated)
      get   'tutors/info'     => 'tutors#show'
      patch 'tutors/info'     => 'tutors#edit'
      post  'tutors/rate'     => 'tutors#rate'
      post  'tutors/signup'   => 'tutors#create'
      delete'tutors/signout'  => 'tutors#destroy'
      post  'tutors/appointments'     => 'tutors#appointments'
      post  'tutors/activate_account' => 'tutors#activate_account'
      post  'tutors/reset_password'   => 'tutors#reset_password'
      get   'tutors/send_verification_code' => 'tutors#send_verification_code'

      # payments
      post 'payments/pay' => 'payments#pay'
      post 'payments/notify' => 'payments#notify'
      post 'payments/discount' => 'payments#discount'
      post 'payments/add_discount' => 'payments#add_discount'

      # voice
      post  'voice/response/conference' => 'voice#answer'
      post  'voice/hangup'    => 'voice#hangup'
      post  'voice/reconnect' => 'voice#reconnect'
      post  'voice/waitmusic' => 'voice#waitmusic'

      # topic
      get 'topic/getall' => 'topics#getall'
      post 'topic/new' => 'topics#new'

      # certificate
      post 'certificate/new' => 'certificates#create'
      get 'certificate/verify' => 'certificates#verify_certificate'

      # version control
      post  'version/check' => 'version#version_check'
      post  'version/add' => 'version#add_version'
    end
  end

  # (updated) authenticate the student
  post 'authenticate/student' => 'authentication#authenticate_student'
  post 'authenticate/tutor' => 'authentication#authenticate_tutor'
  
  # get config info
  get 'config/infos' => 'application#get_config_infos'

  # get the server url
  get 'server/url' => 'application#get_server_url'

  # version control
  post  'version/check' => 'api/v1/version#version_check'
  post  'version/add' => 'api/v1/version#add_version'

  # sidekiq
  mount Sidekiq::Web, at: '/sidekiq'

  match '*path', to: 'api#invalid_api', via: :all
end
