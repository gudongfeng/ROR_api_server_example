class SendSmsJob < ApplicationJob
  queue_as :default

  def perform(phone, country_code, code, language="english")
    url = Settings.Yunpian.sms_url
    apikey = Settings.Yunpian.apikey

    # set the locale
    if language.eql? "chinese"
      I18n.locale = 'cn'
    else
      I18n.locale = I18n.default_locale
    end

    text = I18n.t 'success.messages.code', code: code
    mobile = country_code.to_s + phone
    mobile = "%2B#{mobile}"
    HTTP.headers(:accept => "application/json",
                 'Content-Type': 'application/x-www-form-urlencoded')
        .post(url, :body => "apikey=#{apikey}&text=#{text}&mobile=#{mobile}")

  end
end
