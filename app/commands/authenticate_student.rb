class AuthenticateStudent
  prepend SimpleCommand

  def initialize(phone, password)
    @phone = phone
    @password = password
  end

  def call
    JsonWebToken.encode(student_id: student.id) if student
  end

  private

  attr_accessor :phone, :password

  def student
    student = Core::Student.find_by(phoneNumber: phone)
    return student if student && student.authenticate(password)

    errors.add :student_authentication, I18n.t('error.messages.token.credential')
    nil
  end
end