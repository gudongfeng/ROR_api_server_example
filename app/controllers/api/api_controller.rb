class Api::ApiController < ApplicationController
  # All other invalid API
  api :GET, '/<invalid>', 'all other invalid api'
  api :PUT, '/<invalid>', 'all other invalid api'
  api :POST, '/<invalid>', 'all other invalid api'
  api :DELETE, '/<invalid>', 'all other invalid api'
  api_version 'root'
  def invalid_api
    render :json => I18n.t('not_found'), :status => :not_found
  end
end
