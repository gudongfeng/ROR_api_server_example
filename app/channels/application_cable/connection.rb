module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      # pass the type parameter in the request
      # puts request.params['type']
      # puts request.headers['Authorization']
      self.current_user = find_verified_user
    end

    protected

    # Authorize connection
    def find_verified_user
      if request.params['type'] == 'student'
        AuthorizeApiRequest.call('student', request.headers).result
      elsif request.params['type'] == 'tutor'
        AuthorizeApiRequest.call('tutor', request.headers).result
      else
        reject_unauthorized_connection
      end
    end
  end
end
