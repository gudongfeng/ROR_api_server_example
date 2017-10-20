class ApplicationController < ActionController::API
  before_action :set_locale

  # ROOT page
  def hello
    render :json => 'hello, world!', :status => :ok
  end

  # get the server address
  def get_server_url
    if params && params[:version] && params[:type]
      app_version = Core::Version.find_by(name: params[:version], app_type: params[:type])
      current_version = params[:version].split('.').map{|s|s.to_i}
      latest_version = Core::Version.where(app_type: params[:type]).last.name.split('.').map{|s|s.to_i}
      if app_version.nil? && (current_version <=> latest_version) >= 0
        # this version is the develop version, doesn't exist in our data set
        render :json => {message: Settings.client_heroku_dev_server}, :status => 200
      else
        # otherwise get the production url
        render :json => {message: Settings.client_heroku_server}, :status => 200
      end
    else
      # otherwise get the production url
      render :json => {message: Settings.client_heroku_server}, :status => 200
    end
  end

  # get the configuration file information
  def get_config_infos
    configinfo =
        {
            :init_one_appointment_price => Settings.init_one_appointment_price,
            :income_call_number => Settings.income_call_number,
            :call_length => Settings.call_length,
            :tutor_online_time => Settings.tutor_online_time,
            :call_delay_time => Settings.call_delay_time,
            :tutor_single_price => Settings.tutor_single_price
        }
    render :json => configinfo.to_json(), :status => 200
  end

  protected

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  # (Updated) Return the model saving error
  def save_model_error object
    error_str = I18n.t 'term.error'
    error_str += ' : '
    # Grab the error message from the student
    object.errors.each do |attr,msg|
      error_str += "#{attr} - #{msg},"
    end
    render :json => { error: error_str }, :status => :unprocessable_entity
  end

  # (Updated) Parameters missing error
  def render_params_missing_error
    render :json => { error: I18n.t('api.errors.parameters') },
           :status => :bad_request
  end

  # (Updated) General error
  def render_error(message, status)
    render json: { error: message }, status: status
  end
  
  # (Updated) General success message
  def render_message(message)
    render json: { message: message }, status: :ok
  end

end
