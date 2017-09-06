class Api::V1::TutorMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.api.v1.tutor_mailer.account_activation.subject
  #
  def account_activation(tutor)
    @tutor = tutor
    mail to: tutor.email, subject: "Account activation"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.api.v1.tutor_mailer.password_rese.subject
  #
  def password_reset(tutor)
    @tutor = tutor
    mail to: tutor.email, subject: "Password reset"
  end
end
