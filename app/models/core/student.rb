module Core
  class Student < ApplicationRecord
    include SmsUtil

    # ==========================================================================
    # STUDENT MODEL CALLBACKS
    # ==========================================================================    
    # The emails save in the Database are downcase
    before_save :downcase_email

    # ==========================================================================
    # STUDENT MODEL ASSOCIATIONS
    # ==========================================================================
    # associations with requests
    has_many :requests
    # associations with appointments via tutors
    has_many :appointments
    has_many :tutors, through: :appointments

    # ==========================================================================
    # STUDENT ATTRIBUTE OPERATION AND VALIDATION
    # ==========================================================================
    # This allows the activation_token to be virtual
    attr_accessor :activation_token, :reset_token
    
    # Set the password, bcrypt gem
    has_secure_password
    # Name valid expression
    validates :name, presence: true, length: { maximum: 50 }
    # Email valid expression
    VALID_EMAIL_REGEX = /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/
    validates :email, allow_nil: true, length: { maximum: 255 },
              format: { with: VALID_EMAIL_REGEX },
              uniqueness: {case_sensitive: false}
    # Phone number valid expression, can only be number
    VALID_PHONE_REGEX = /\A[+-]?\d+\Z/
    validates :phoneNumber, presence: true, uniqueness: true,
              format: { with: VALID_PHONE_REGEX }
    validates :password, length: { minimum: 6 }, :on => [:create]
    validates :gender, inclusion: { in: %w(male female) }, presence: true
    validates :country_code, inclusion: {in: [1, 86]}, presence: true
    validates :picture, presence: true
    validates :state, inclusion: { in: %w(requesting online meeting offline)},
              presence: true

    # ==========================================================================
    # STUDENT FUNCTIONS
    # ==========================================================================
    # (updated)
    def to_json(options={})
      options[:except] ||= [:password_digest, :created_at, :updated_at,
                            :activated, :activated_at, :session_count]
      super(options)
    end

    # (updated)
    def as_json(options={})
      options[:except] ||= [:password_digest, :created_at, :updated_at,
                            :activated, :activated_at, :session_count]
      super(options)
    end
    
    # (updated) activates an account.
    def activate
      # clear the verification code
      clear_verification_code
      update_attribute(:activated, true)
      update_attribute(:activated_at, Time.zone.now)
    end

    # (updated) change student state
    def change_state(state)
      update_attribute(:state, state)
      # Notify the student about the state change
      MessageBroadcastJob.perform_later(state,
                                        'state',
                                        student_id: self.id)
    end

    # (updated) send a new verfication code through sms
    def send_verification_sms
      send_sms
    end

    # Send push notifications to student
    def send_push(msg, silent = false)
      return 'failure' if self.device_token.blank? || self.device_token.eql?('EMPTY')
      n = Rpush::Apns::Notification.new
      n.app = Rpush::Apns::App.find_by_name("talkwithsam_student")
      n.device_token = self.device_token # 64-character hex string
      n.alert = msg
      n.content_available = silent
      dt = get_current_status
      n.data = dt
      begin
        n.save!
      rescue Exception => e
        p "Push message failed to send because #{e.message}!"
      end
    end
    
    # (updated) clean the verification code
    def clear_verification_code
      update_attribute(:verification_code, nil)
    end

    # private functions
    private

    
    # Converts email to all lower-case.
    def downcase_email
      if !self.email.nil?
        self.email = email.downcase
      end
    end

    # Get a list of tutors that are disliked
    def disliked_tutors
      tutors = []
      self.appointments.where(student_rating: [nil, 0]).each do |ap|
        tutors.push(ap.tutor)
      end
      tutors
    end

    # Get a list of tutors who have declined this session
    def declined_tutors_for_session(s_id)
      tutors = []
      #tutors.push(nil)
      self.requests.where(session_id: s_id).each do |rq|
        tutors.push(rq.tutor)
      end
      tutors
    end

    # Get a list of tutors who have declined this session
    def available_tutors
      tutors = []
      Core::Tutor.where(state: 'available').each do |tutor|
        tutors.push(tutor)
      end
      tutors
    end
  end
end
