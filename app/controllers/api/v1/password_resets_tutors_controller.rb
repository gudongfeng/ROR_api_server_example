class Api::V1::PasswordResetsTutorsController < Api::ApiController

  before_action :get_tutor,   only: [:edit, :update]
  before_action :valid_tutor, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]
  before_action :set_locale
  
  def create
    @tutor = Core::Tutor.find_by(email: params[:email].downcase)
    if @tutor
      @tutor.create_reset_digest
      @tutor.send_password_reset_email
      render :json => {:message => (I18n.t 'success.messages.email_pass_reset')},
             :status => 200
    else
      json_error_message 400, (I18n.t 'error.messages.no_email')
    end
  end

  def edit
  end

  def update
  	if params[:core_tutor] && params[:core_tutor][:password].empty?
      flash.now[:danger] = I18n.t 'error.messages.email_pass_flash.empty'
      render 'edit'
    elsif params[:core_student][:password].length < 6
      flash.now[:danger] = I18n.t 'error.messages.email_pass_flash.length'
      render 'edit'
    elsif @tutor.update_attributes(tutors_params)
      flash.now[:success] = I18n.t 'success.messages.pass_reset'
      @tutor.update_attribute(:remember_token, nil)
      render 'edit'
    else
      render 'edit'
    end
  end

  private

    def tutors_params
      params.require(:core_tutor).permit(:password, :password_confirmation)
    end

    def get_tutor
      @tutor = Core::Tutor.find_by(email: params[:email])
    end

    # Confirms a valid user.
    def valid_tutor
      unless (@tutor && @tutor.activated? &&
              @tutor.authenticated?(:reset, params[:id]))
        json_error_message 400, (I18n.t 'error.messages.no_account')
      end
    end

    # Checks expiration of reset token.
    def check_expiration
      if @tutor.password_reset_expired?
        flash.now[:danger] = I18n.t 'error.messages.email_pass_flash.expire'
      end
    end
end
