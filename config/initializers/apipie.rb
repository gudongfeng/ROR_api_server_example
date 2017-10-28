Apipie.configure do |config|
  config.app_name                = "TWSServer"
  config.api_base_url['v1']      = "/api/v1"
  config.api_base_url['root']    = ""
  config.doc_base_url            = "/api_doc"
  # where is your API defined?
  config.api_controllers_matcher = File.join(Rails.root, "app", "controllers", "**","*.rb")
  config.default_version         = "v1"
  config.app_info['v1'] = "v1 API"
  config.app_info['root'] = "the root API"
  config.validate = false
  # i18n localization setting
  config.default_locale = 'en'
  config.languages = ['en']

  # add the authentication for the production
  # add authenticate to api document
  # config.authenticate = Proc.new do
  #   authenticate_or_request_with_http_basic do |username, password|
  #     username == "talkwithsam" && password == "supersam"
  #   end
  # end
end
