class AuthorizeApiRequest
  prepend SimpleCommand

  def initialize(role, headers = {})
    @role = role
    @headers = headers
  end

  def call
    if @role == 'student'
      student
    elsif @role == 'tutor'
      tutor
    else
      nil
    end
  end

  private

  attr_reader :headers

  def student
    @student ||= Core::Student.find(decoded_auth_token[:student_id]) if decoded_auth_token
    @student || errors.add(:token, I18n.t('error.messages.token.invalid')) && nil
  end

  def tutor
    @tutor ||= Core::Tutor.find(decoded_auth_token[:tutor_id]) if decoded_auth_token
    @tutor ||= errors.add(:token, I18n.t('error.messages.token.invalid')) && nil
  end

  def decoded_auth_token
    @decoded_auth_token ||= JsonWebToken.decode(http_auth_header)
  end

  def http_auth_header
    if headers['Authorization'].present?
      return headers['Authorization'].split(' ').last
    else
      errors.add(:token, I18n.t('error.messages.token.missing'))
    end
    nil
  end
end