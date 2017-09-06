class Api::V1::AccountActivationsController < Api::ApiController
  def edit
    @user = Core::Tutor.find_by(email: params[:email].downcase)
    @user = Core::Student.find_by(email: params[:email].downcase) if !@user

    if @user && !@user.activated? && @user.authenticated?(:activation, params[:id])
      @user.activate
      # render :json => {:message => 'Account activated!'}, :status => 200
      # render :partial => '/activations/activation_succ'
      render html: "<p>Hi #{@user.name},</p><p>Welcome to Talk With Sam! Your account has been activated!</p>".html_safe
    else
      # json_error_message 400, 'Invalid activation link'
      # render :partial => '/activations/activation_fail'
      render html: "<p>The link you clicked is not valid!</p>".html_safe

    end
  end
end
