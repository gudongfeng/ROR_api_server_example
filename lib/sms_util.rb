module SmsUtil
  # generate a new verification code and send verification sms
  def send_sms
    # generate sms verification code
    number = rand.to_s[2..5]
    self.update_attribute(:verification_code, number)
    # if the phone number is chinese phone number , then send the chinese phone number
    if self.country_code.eql? 86
      SendSmsJob.perform_later self.phoneNumber, self.country_code,
        self.verification_code, 'chinese'
    else
      SendSmsJob.perform_later self.phoneNumber, self.country_code,
        self.verification_code
    end
  end
end

