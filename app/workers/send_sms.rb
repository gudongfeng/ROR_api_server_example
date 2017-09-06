require 'http'

class SendSms < ActionController::Base
  include Sidekiq::Worker

  def perform phone_number, code, language="english"

    url = Settings.Yunpian.sms_url
    apikey = Settings.Yunpian.apikey

    # set the locale
    if language.eql? "chinese"
      I18n.locale = 'cn'
    else
      I18n.locale = I18n.default_locale
    end

    text = I18n.t 'success.messages.code', code: code
    mobile = "%2B#{phone_number}"
    HTTP.headers(:accept => "application/json",
                 'Content-Type': 'application/x-www-form-urlencoded')
        .post(url, :body => "apikey=#{apikey}&text=#{text}&mobile=#{mobile}")

  end

  # def perform phone_number, code, language="english"
  #   init
  #   p = RestAPI.new(@AUTH_ID, @AUTH_TOKEN)
  #   text = "Verification code: #{code}. You use TalkWithSam now and validation is required."
  #   if language.eql? "chinese"
  #     text = "验证码为: #{code}, 您正在使用 TalkWithSam 认证服务"
  #   end
  #   # send SMS
  #   params = {
  #       'dst' => "#{phone_number}",
  #       # The phone number to be used as the sender
  #       'src' => "#{Settings.income_call_number}",
  #       'text' => text
  #   }
  #   p.send_message(params)
  # end

  # def init
  #   @AUTH_ID = Settings.Plivo.auth_id
  #   @AUTH_TOKEN = Settings.Plivo.auth_token
  # end


end