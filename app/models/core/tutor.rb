module Core
  class Tutor < ApplicationRecord
    include SmsUtil

    # ==========================================================================
    # TUTOR MODEL CALLBACKS
    # ==========================================================================
    # The emails save in the Database are downcase
    before_save :downcase_email
    # Initialize some fields to empty rather than null
    after_initialize :init

    # ==========================================================================
    # TUTOR MODEL ASSOCIATIONS
    # ==========================================================================
    # associations with requests
    has_many :requests
    # associations with educations / work experiences
    has_many :educations, dependent: :destroy
    # associations with appointments via students
    has_many :appointments
    has_many :students, through: :appointments

    # ==========================================================================
    # TUTOR ATTRIBUTE OPERATION AND VALIDATION
    # ==========================================================================
    # This allows the activation_token to be virtual
    attr_accessor :activation_token, :reset_token
    
    # Set the password， bcrypt gem
    has_secure_password
    # Name valid expression
    validates :name, presence: true, length: { maximum: 50 }
    # Phone number valid expression, can only be number
    VALID_PHONE_REGEX = /\A[+-]?\d+\Z/
    validates :phoneNumber, 
              format: { with: VALID_PHONE_REGEX },
              uniqueness: true,
              presence: true
    # Email valid expression
    VALID_EMAIL_REGEX = /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/
    validates :email, presence: true, length: { maximum: 255 },
              format: { with: VALID_EMAIL_REGEX },
              uniqueness: { case_sensitive: false }
    validates :password, length: {minimum: 6}, :on => :create
    validates :country_code, presence: true, inclusion: { in: [1, 86] }
    validates :picture, presence: true
    validates :gender, presence: true, inclusion: { in: %w(male female) }

    # ==========================================================================
    # TUTOR FUNCTIONS
    # ==========================================================================

    def to_json(options={})
      options[:except] ||= [:password_digest, :created_at, :updated_at,
                            :activated, :activated_at]
      super(options)
    end

    # (updated) Activate tutor account
    def activate
      update_attribute(:activated, true)
      update_attribute(:activated_at, Time.zone.now)
    end

    # (updated) send a new verfication code through sms
    def send_verification_sms
      send_sms
    end

    # (updated) clean the verification code attribute
    def clear_verification_code
      self.update_attribute(:verification_code, nil)
    end

    # Sets the password reset attributes.
    def create_reset_digest
      self.reset_token = Tutor.new_token
      update_attribute(:reset_digest, Tutor.digest(reset_token))
      update_attribute(:reset_sent_at, Time.zone.now)
    end

    # Returns true if the given token matches the digest.
    def authenticated?(attribute, token)
      digest = send("#{attribute}_digest")
      return false if digest.nil?
      BCrypt::Password.new(digest).is_password?(token)
    end

    # Sends activation email.
    def send_activation_email
      Api::V1::TutorMailer.account_activation(self).deliver_now
    end

    # Sends password reset email.
    def send_password_reset_email
      Api::V1::TutorMailer.password_reset(self).deliver_now
    end

    # Returns true if a password reset has expired.
    def password_reset_expired?
      reset_sent_at < 2.hours.ago
      # reset_sent_at < 1.minutes.ago
    end

    # Tutor can reply to a student's request
    def request_reply(request_id, request_reply)
      request = self.requests.find_by_id(request_id)

      return request && request.reply(request_reply)
    end


    # Send push notifications to tutor
    def send_push(msg, silent = false, sound = false)
      return 'failure' if self.device_token.blank? || self.device_token.eql?('EMPTY')
      n = Rpush::Apns::Notification.new
      n.app = Rpush::Apns::App.find_by_name("talkwithsam_tutor")
      n.device_token = self.device_token # 64-character hex string
      n.alert = msg
      n.content_available = silent
      if sound
        n.sound = "2.m4a"
      end
      dt = get_current_status
      n.data = dt
      begin
        n.save!
      rescue Exception => e
        Rails.logger.error "Push message failed to send because #{e.message}!"
      end
    end

    # private functions to help
    private

    # Converts email to all lower-case.
    def downcase_email
      self.email = email.downcase
    end

    # (updated) initialize value
    def init
      self.country ||= ''
      self.picture ||= ''
      self.region ||= ''
      self.description ||= ''
      self.balance ||= 0
      self.decline_count ||=0
    end

    def return_error_message object
      error_str = ''
      # Grap the error message from the student
      object.errors.each do |attr, msg|
        error_str += "#{attr} - #{msg},"
      end
      error_str
    end

  end
end
