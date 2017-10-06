class Api::V1::CertificatesController < Api::ApiController

  before_action :check_for_valid_authtoken,
                :only => [:verify_certificate]
  before_action :set_locale

  # Create a new certificate
  def create
    if params && params[:name] && params[:picture_url] && params[:level] &&
        params[:requirement_num] && params[:description] && params[:origin_picture_url]
      certificate = Core::Certificate.new(certificate_create_param)
      if certificate.save
        render :json => {message: (I18n.t 'success.messages.certificate')}, :status => 200
      else
        save_model_error certificate
      end
    else
      json_error_message 400, (I18n.t 'error.messages.parameters')
    end
  end

  # Check the student certification
  def verify_certificate
    if @student && @student.remember_expiry > Time.now
      # first verification
      five_star_result = five_stars
      # second verification
      appointment_number_result = appointment_number

      # sum up all the certificate
      certificate_result = []
      certificate_result.push five_star_result if !five_star_result.nil?
      certificate_result.push appointment_number_result if !appointment_number_result.nil?
      render :json => certificate_result,
             :status => 200
    else
      json_error_message 401, (I18n.t 'error.messages.login')
    end

  end

  private

  def certificate_create_param
    params.permit(:name, :picture_url, :level, :requirement_num,
                  :description, :origin_picture_url)
  end

  # First verification (five stars counts)
  def five_stars
    if @student
      # get the student five star appointment number
      five_star_count = @student.appointments
                            .select { |appointment| !appointment.tutor_rating.nil? }
                            .select { |appointment| appointment.tutor_rating.eql?('5') }
                            .size

      result = general_cert_check 'five_star', five_star_count
      result['name'] = '五星证书' if !result.nil?
      return result
    end
  end

  # Second verification (the appointment number)
  def appointment_number
    if @student
      # get the student appointment number
      appointment_count = @student.appointments.size
      result = general_cert_check 'appointment_number', appointment_count
      result['name'] = '预约证书' if !result.nil?
      return result
    end
  end

  def general_cert_check name, current_count
    cert_array = []
    cert_objs = Core::Certificate.where(name: name).order(:requirement_num)
    cert_objs.each do |certificate|
      tmp = certificate.as_json()
      tmp[:satisfied] = false
      if current_count >= certificate.requirement_num
        tmp[:satisfied] = true
      end
      cert_array.push tmp
    end

    # Set the current progress
    latest_cert = cert_array.select { |certificate| certificate[:satisfied] == true }.last
    if latest_cert.nil?
      return nil
    else
      latest_cert[:current_progress] = current_count

      # Set the next requirement
      if cert_array.select { |certificate| !certificate[:satisfied]}.empty?
        latest_cert[:next_requirement] = latest_cert['requirement_num']
      else
        latest_cert[:next_requirement] = cert_array.select { |certificate| !certificate[:satisfied] }
                                             .first()['requirement_num']
      end

      # remove the requirement num attribute and the satisfied attribute
      latest_cert.except!('requirement_num', :satisfied)

      return latest_cert
    end
  end

  # Check the student authtoken
  def check_for_valid_authtoken
    authenticate_or_request_with_http_token do |token, options|
      @student = Core::Student.find_by(remember_token: token)
    end
  end
end