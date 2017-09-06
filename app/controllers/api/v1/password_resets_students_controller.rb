class Api::V1::PasswordResetsStudentsController < Api::ApiController

  before_action :get_student,   only: [:edit, :update]
  before_action :valid_student, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]
  before_action :set_locale
  
  def create
    @student = Core::Student.find_by(email: params[:email].downcase)
    if @student
      @student.create_reset_digest
      @student.send_password_reset_email
      render :json => {:message => (I18n.t 'success.messages.email_pass_reset')},
             :status => 200
    else
      json_error_message 400, (I18n.t 'error.messages.no_email')
    end
  end

  def edit
  end


  def update
  	if params[:core_student][:password].empty?
      flash.now[:danger] = I18n.t 'error.messages.email_pass_flash.empty'
      render 'edit'
    elsif params[:core_student][:password].length < 6
      flash.now[:danger] = I18n.t 'error.messages.email_pass_flash.length'
      render 'edit'
    elsif @student.update_attributes(students_params)
      flash.now[:success] = I18n.t 'success.messages.pass_reset'
      @student.update_attribute(:remember_token, nil)
      render 'edit'
    else
      render 'edit'
    end
  end


  private

    def students_params
      params.require(:core_student).permit(:password, :password_confirmation)
    end

    def get_student
      @student = Core::Student.find_by(email: params[:email])
    end

    # Confirms a valid user.
    def valid_student
      unless (@student && @student.activated? &&
              @student.authenticated?(:reset, params[:id]))
        json_error_message 400, (I18n.t 'error.messages.no_account')
      end
    end

    # Checks expiration of reset token.
    def check_expiration
      if @student.password_reset_expired?
        flash.now[:danger] = I18n.t 'error.messages.email_pass_flash.expire'
      end
    end
end
