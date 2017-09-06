class Api::V1::StudentMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.api.v1.student_mailer.account_activation.subject
  #
  def account_activation(student)
    @student = student
    mail to: student.email, subject: "Account activation"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.api.v1.student_mailer.password_reset.subject
  #
  def password_reset(student)
    @student = student
    mail to: student.email, subject: "Password reset"
  end
end
