# frozen_string_literal: true

# Main Application controller
class ApplicationController < ActionController::API
  before_action :set_locale

  # ROOT page
  def hello
    render json: 'hello, world!', status: :ok
  end

  # All other invalid API
  api :GET, '/<invalid>', 'all other invalid api'
  api :PUT, '/<invalid>', 'all other invalid api'
  api :POST, '/<invalid>', 'all other invalid api'
  api :DELETE, '/<invalid>', 'all other invalid api'
  api_version 'root'
  def invalid_api
    render(json: I18n.t('not_found'), status: :not_found)
  end

  protected

  # @param [Array] params_arr: the param you need to check
  # @param [String] type: name of the first level of params
  # @return [Boolean]: the params exist or not
  def params?(params_arr, type = nil)
    return false unless params
    if type.nil?
      params_arr.each do |param|
        return false unless params[param]
      end
    else
      return false unless params[type]
      params_arr.each do |param|
        return false unless params[type][param]
      end
    end
    true
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  # Return the model saving error
  def save_model_error(object)
    error_str = I18n.t 'term.error'
    error_str += ' : '
    # Grab the error message from the student
    object.errors.each do |attr, msg|
      error_str += "#{attr} - #{msg},"
    end
    render json: { error: error_str }, status: :unprocessable_entity
  end

  # Parameters missing error
  def render_params_missing_error
    render json: { error: I18n.t('api.errors.parameters') },
           status: :bad_request
  end

  # General error
  def render_error(message, status)
    render json: { error: message }, status: status
  end

  # General success message
  def render_message(message)
    render json: { message: message }, status: :ok
  end
end
