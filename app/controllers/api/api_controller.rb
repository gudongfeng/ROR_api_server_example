# frozen_string_literal: true

module Api
  # General function
  class ApiController < ApplicationController
    protected

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
