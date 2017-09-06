class JsonWebToken
  class << self
    def encode(payload, exp = Time.now.to_i + Settings.login_expiry_time)
      payload[:exp] = exp
      JWT.encode(payload, Rails.application.secrets.secret_key_base)
    end

    def decode(token)
        body = JWT.decode(token, Rails.application.secrets.secret_key_base)[0]
        HashWithIndifferentAccess.new body
      rescue
        nil
    end
  end
end