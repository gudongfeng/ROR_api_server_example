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
      post  'students/signup'  => 'students#create'
      delete'students/signout' => 'students#destroy'
      post  'students/activate_account' => 'students#activate_account'
      post  'students/reset_password'   => 'students#reset_password'
      get   'students/send_verification_code' => 'students#send_verification_code'

      # (not update)
      post  'students/verify_token' => 'students#verify_token'
      post  'students/check_email' => 'students#check_email'
      post  'students/verify_verification_code' => 'students#verify_verification_code'
      get   'students/all_appointments' => 'students#get_all_appointments'

      # teacher info
      # (updated)
      get   'tutors/info'     => 'tutors#show'
      patch 'tutors/info'     => 'tutors#edit'
      post  'tutors/rate'     => 'tutors#rate'
      post  'tutors/signup'   => 'tutors#create'
      delete'tutors/signout'  => 'tutors#destroy'
      post  'tutors/activate_account' => 'tutors#activate_account'
      post  'tutors/reset_password'   => 'tutors#reset_password'
      get   'tutors/send_verification_code' => 'tutors#send_verification_code'

      # (not update)
      post  'tutors/verify_token' => 'tutors#verify_token'
      post  'tutors/check_email' => 'tutors#check_email'

      # new reservation system
      post  'tutors/change_state' => 'tutors#change_state'
      get   'tutors/status' => 'tutors#get_status'
      post  'tutors/request_get_student' => 'tutors#request_get_student'
      post  'tutors/request_reply' => 'tutors#request_reply'
      post  'appointments/tutors/rate_feedback' => 'tutors#rate_feedback'
      post  'students/tutors_online_count' => 'students#tutors_online_count'
      post  'students/tutor_state' => 'students#tutor_state'
      
      post  'students/request_get_tutor' => 'students#request_get_tutor'
      post  'students/request_look_for_tutors' => 'students#request_look_for_tutors'
      post  'students/request_cancel_look_for_tutors' => 'students#request_cancel_look_for_tutors'
      post  'students/request_look_for_prioritized_tutor' => 'students#request_look_for_prioritized_tutor'
      post  'appointments/students/rate_feedback' => 'students#rate_feedback'
      

      # appointment
      get   'students/appointments' => 'appointments#all_appointments_student'
      get   'tutors/appointments' => 'appointments#all_appointments_tutor'
      post  'appointments/manually_terminate' => 'appointments#manually_terminate_appointment'
      post  'appointments/get_by_id' => 'appointments#get_appointment_from_id'

      # account_activations
      resources :account_activations, only: [:edit]

      # password_reset
      resources :password_resets_students, only: [:create, :edit, :update]
      resources :password_resets_tutors, only: [:create, :edit, :update]

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
