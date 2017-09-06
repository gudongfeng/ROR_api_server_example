class Api::V1::TopicsController < Api::ApiController

  before_action :set_locale

  def new
    # create a topic in the database
    if params && params[:name]
      topic = Core::Topic.new params.permit :name
      if topic.save
        render :json => {:message => (I18n.t 'success.messages.create_topic')},
               :status => 200
      else
        save_model_error topic
      end
    else
      json_error_message 400, (I18n.t 'error.messages.parameters')
    end
  end

  # get all the topics from the database
  def getall
      render :json => Core::Topic.all.to_json, :status => 200
  end
end
