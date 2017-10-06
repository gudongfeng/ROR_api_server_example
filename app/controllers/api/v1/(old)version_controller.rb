class Api::V1::VersionController < Api::ApiController
  before_action :set_locale


  # check the app version
  def version_check
    if params && params[:version] && params[:type]
      app_version = Core::Version.find_by(name: params[:version], app_type: params[:type])
      current_version = params[:version].split('.').map{|s|s.to_i}
      latest_version = Core::Version.where(app_type: params[:type]).last.name.split('.').map{|s|s.to_i}
      if !app_version.nil? || (current_version <=> latest_version) >= 0
        # the current version is larger or equal to the latest version in the database
        if (current_version <=> latest_version) >= 0
          # the app version is latest version
          render :json => {:message => '2'}, :status => 200
        else
          # the app version is not the latest version
          if app_version.force_update
            # need to update this version
            render :json => {:message => '0'}, :status => 200
          else
            # don not need to update this version
            render :json => {:message => '1'}, :status => 200
          end
        end
      else
        return_error_message 400, (I18n.t 'error.messages.version')
      end
    else
      json_error_message 400, (I18n.t 'error.messages.parameters')
    end
  end

  # add a new version to the database
  def add_version
    if params && params[:version] && params[:app_type]
      # set the version name
      params[:name] = params[:version]
      version = Core::Version.new(version_parameters)
      if version.save
        # successfully create the version data
        render :json => {:message => (I18n.t 'success.messages.version')}, :status => 200
      else
        save_model_error version
      end
    else
      json_error_message 400, (I18n.t 'error.messages.parameters')
    end
  end

  private

  # version parameters
  def version_parameters
    params[:force_update] = false
    params.permit(:name, :app_type, :force_update)
  end


end