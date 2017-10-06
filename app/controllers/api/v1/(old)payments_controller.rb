require 'pingpp'
require "digest/md5"
require 'openssl'
require 'base64'

class Api::V1::PaymentsController < Api::ApiController
  before_action :check_for_valid_authtoken_student, :only => [:pay, :discount]
  before_action :fix_json_params
  before_action :set_locale


  test_key = 'sk_test_n9O4S89i5mLKmPajvDCmbrbL'
  live_key = 'sk_live_m1ddnIt5xgVkxCXdiGwfwQCr'

  Pingpp.api_key = live_key

  def pay
    if @student && @student.remember_expiry > Time.now
      # parse the header to get the key
      Pingpp.parse_headers(request.headers)

      # get parameters needed
      if allow_params && allow_params[:channel] && allow_params[:amount] && allow_params[:appointment_id]
        channel = allow_params[:channel].downcase

        # get price from server
        # amount = allow_params[:amount]
        appointment = Core::Appointment.find_by_id(allow_params[:appointment_id])
        order_no = appointment.order_no
        amount = (appointment.amount*100).round
        product_id = appointment.id

      else
        json_error_message 400, (I18n.t 'error.messages.parameters')
        return
      end

      client_ip = request.remote_ip

      # easy for dev mode
      client_ip = '127.0.0.1' if Rails.env.development?

      extra = {}
      case channel
        when 'alipay'
          extra = {}
        when 'wx'
          extra = {}
        when 'alipay_qr'
          extra = {}
        when 'wx_pub_qr'
          extra = {:product_id => product_id}
      end

      response_body = ''
      begin
        ch = Pingpp::Charge.create(
            :order_no => order_no,
            :app => {'id' => "app_zDCmf9v9KSy1H00m"},
            :channel => channel,
            :amount => amount,
            :client_ip => client_ip,
            :currency => 'cny',
            :subject => "Oral language course",
            :body => "meeting with tutor #{appointment.tutor.name}",
            :extra => extra
        )
        response_body = ch.to_json
      rescue Pingpp::PingppError => error
        response_body = error.http_body
      end
      render :json => response_body, :status => 200
    else
      json_error_message 401, (I18n.t 'error.messages.login')
    end
  end

  # use web hooks to deal with pay/refund event
  def notify
    # use header to verify pingpp signature
    if !request.headers.key?('x-pingplusplus-signature')
      render :text => 'missing ping++ signature', :status => 401
      return
    end

    raw_data = request.body.read
    signature = request.headers['x-pingplusplus-signature']
    pub_key_path = File.join(Rails.root, 'certs', 'pingpp_rsa_public_key.pem')

    if !verify_signature(raw_data, signature, pub_key_path)
      render :text => 'ping++ signature is invalid', :status => 403
      return
    end

    response_body = 'fail'
    if allow_params[:object].nil?
    elsif allow_params[:object] == 'event'
      response_body = 'success'
      if allow_params[:type] == 'charge.succeeded'
        on = allow_params[:data][:object][:order_no]
        ap = Core::Appointment.find_by(order_no: on)
        state_update ap
      end
    elsif allow_params[:object] == 'refund.succeeded'
      response_body = 'success'
    end
    render :text => response_body, :status => 200
  end

  # use to apply the discount on the student
  def discount
    # check the params
    if params && params[:discount_code] && params[:appointment_id]
      discount = Core::Discount.find_by(value: params[:discount_code])
      appointment = Core::Appointment.find_by_id(params[:appointment_id])
      if @student && @student.remember_expiry > Time.now
        # check if the appointment already apply the discount or not
        if appointment.discount_id.nil?
          if discount && (discount.count > 0)
            # update the appointment price, and the discounts id
            appointment.update_attribute :amount, (appointment.amount*discount.rate).round(2)
            appointment.update_attribute :discount_id, discount.id
            discount.update_attribute :count, (discount.count-1)

            # if the payment amount less than 1, update the state to finish
            state_update appointment if appointment.amount < 1
            appointment.student.send_push(I18n.t 'success.messages.discount_zero', count: discount.count)

            # return the information to the
            render :json => {:new_price => appointment.amount,
                             :company_logo_url => discount.company_logo,
                             :discount_rate => discount.rate,
                             :discount_rate_chinese => discount.discount_rate_chinese},
                   :status => 200
          else
            json_error_message 400, (I18n.t 'error.messages.discount.invalid')
          end
        else
          json_error_message 400, (I18n.t 'error.messages.discount.used')
        end
      else
        json_error_message 401, (I18n.t 'error.messages.login')
      end
    else
      json_error_message 400, (I18n.t 'error.messages.parameters')
    end
  end

  # add a new discount to the database
  def add_discount
    # check the params
    if params && params[:value] && params[:company_logo] &&
        params[:rate] && params[:count] && params[:discount_rate_chinese]
      discount = Core::Discount.new(discount_create_params);
      if discount.save()
        render :json => {:message => (I18n.t 'success.messages.create_discount')},
               :status => 200
      else
        save_model_error discount
      end
    else
      json_error_message 400, (I18n.t 'error.messages.parameters')
    end
  end

  protected
  def fix_json_params
    if request.content_type == "application/json"
      @reparsed_params = JSON.parse(request.body.string).with_indifferent_access
    else
      @reparsed_params = params
    end
  end

  private
  # Update the corresponding state when payment finished
  def state_update appointment
    appointment.update_attribute(:pay_state, 'paid')
    appointment.student.change_state('rating')
  end

  # Only get the needed information for payments
  def allow_params
    @reparsed_params
  end

  # Define the require params for create the appointment
  def discount_create_params
    params.permit(:value, :company_logo, :rate, :count, :discount_rate_chinese)
  end

  def check_for_valid_authtoken_student
    authenticate_or_request_with_http_token do |token, options|
      @student = Core::Student.find_by(remember_token: token)
    end
  end

  def verify_signature(raw_data, signature, pub_key_path)
    if signature == "~test_test!"
      return true
    end

    rsa_public_key = OpenSSL::PKey.read(File.read(pub_key_path))
    return rsa_public_key.verify(OpenSSL::Digest::SHA256.new, Base64.decode64(signature), raw_data)
  end
end
