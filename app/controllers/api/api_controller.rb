# frozen_string_literal: true

module Api
  # General function
  class ApiController < ApplicationController

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

    # @param [String] code: the ground truth code
    # @return [Boolean]: the code is valid or not
    def code_valid?(code)
      # Error handler
      if code.nil?
        render_error(I18n.t('errors.verification_code.missing'), :not_found)
        return false
      end
      # If the verification code doesn't match
      if code.to_i != params[:verification_code].to_i
        render_error(I18n.t('errors.verification_code.invalid'), :unauthorized)
        return false
      end
      true
    end

  end
end
