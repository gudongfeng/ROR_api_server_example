class AuthenticateTutor
  prepend SimpleCommand

  def initialize(phone, password)
    @phone = phone
    @password = password
  end

  def call
    JsonWebToken.encode(tutor_id: tutor.id) if tutor
  end

  private

  attr_accessor :phone, :password

  def tutor
    tutor = Core::Tutor.find_by(phoneNumber: phone)
    return tutor if tutor && tutor.authenticate(password)

    errors.add :tutor_authentication, I18n.t('error.messages.token.credential')
    nil
  end
end