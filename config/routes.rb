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
      get   'tutors/info'     => 'tutors#show'
      patch 'tutors/info'     => 'tutors#edit'
      post  'tutors/rate'     => 'tutors#rate'
      post  'tutors/signup'   => 'tutors#create'
      delete'tutors/signout'  => 'tutors#destroy'
      post  'tutors/appointments'     => 'tutors#appointments'
      post  'tutors/activate_account' => 'tutors#activate_account'
      post  'tutors/reset_password'   => 'tutors#reset_password'
      get   'tutors/send_verification_code' => 'tutors#send_verification_code'
    end
  end

  # authenticate the student
  post 'authenticate/student' => 'authentication#authenticate_student'
  post 'authenticate/tutor' => 'authentication#authenticate_tutor'

  # sidekiq
  mount Sidekiq::Web, at: '/sidekiq'

  match '*path', to: 'application#invalid_api', via: :all
end
