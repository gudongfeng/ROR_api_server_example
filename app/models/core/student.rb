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
    validates :gender, inclusion: {in: %w(male female)}, presence: true
    validates :country_code, inclusion: {in: [1, 86]}, presence: true
    validates :picture, presence: true

    # ==========================================================================
    # STUDENT FUNCTIONS
    # ==========================================================================
    # (updated)
    def to_json(options={})
      options[:except] ||= [:password_digest, :created_at, :updated_at,
                            :remember_expiry, :activated, :activated_at,
                            :reset_digest, :reset_sent_at, :session_count]
      super(options)
    end

    # Sets the password reset attributes.
    def create_reset_digest
      self.reset_token = Student.new_token
      update_attribute(:reset_digest, Student.digest(reset_token))
      update_attribute(:reset_sent_at, Time.zone.now)
    end


    # (updated) activates an account.
    def activate
      # clear the verification code
      clear_verification_code
      update_attribute(:activated, true)
      update_attribute(:activated_at, Time.zone.now)
    end

    # Sends activation email.
    def send_activation_email
      Api::V1::StudentMailer.account_activation(self).deliver_now
    end

    # (updated) send a new verfication code through sms
    def send_verification_sms
      send_sms
    end

    # Student can set his/her pritorized tutor
    def set_prioritized_tutor(tutor_id)
      update_attributes(prioritized_tutor: tutor_id)
    end

    # Find a tutor that this student likes
    def request_look_for_tutors topic_id, plan_id

      # check if this student is at matching state
      return '现在无法预约' unless self.state == 'matching'

      # keep track of how many tutors have been contacted
      visited_tutor = []

      # get the list of tutors who declined this student's certain session's requests
      declined_tutors = declined_tutors_for_session(self.session_count)

      # get rid of disliked tutors
      candidate_tutors = available_tutors - disliked_tutors - declined_tutors
      return '所有外教在忙' if candidate_tutors.empty?

      # initialize a tutor
      tutor = candidate_tutors.sample
      visited_tutor.push(tutor)

      # check if this tutor has same area of interest topics
      while ((tutor.level < plan_id.to_i) || (!tutor.favour_topic_ids.split('_').include? topic_id.to_s))
        # check if this topic is a free topic or not
        #if topic_id.eql? 1
        #  break;
        #else

        if (candidate_tutors - visited_tutor).empty?
          return '所有外教在忙'
        end

        # find the next available tutor in the database
        tutor = (candidate_tutors - visited_tutor).sample
        visited_tutor.push(tutor)
        #end
      end
      request = self.requests.new(tutor_id: tutor.id, student_id: self.id,
                                  session_id: self.session_count, category: "regular",
                                  topic_id: topic_id, plan_id: plan_id);

      if tutor.state.eql? 'available' and request.save
        return 'success'
      else
        request.destroy
        return 'fail_database_failure'
      end
    end

    # Cancel the request of looking for tutors
    def request_cancel_look_for_tutors(id)

      request = self.requests.where(session_id: id).last

      # change the student state to available
      request.student.change_state 'available' if request.student.state.eql? 'matching'

      # this student doesn't have an ongoing request
      return '当前预约失效' if request.nil?

      # some sync problem and reject the request
      return '当前预约已结束' unless request.state.blank?

      if request.update_attributes(state: 'cancel')
        # job = Sidekiq::ScheduledSet.new.find_job(self.remark1)
        return 'success'
      else
        return 'fail_database_failure'
      end
    end

    # Find a prioritized tutor that this student like
    def request_look_for_prioritized_tutor topic_id, plan_id

      # could not find the prioritized tutor
      return '没有喜欢的外教' if self.prioritized_tutor.blank?

      tutor = Core::Tutor.find_by_id(self.prioritized_tutor)

      # the prioritized tutor for some reason is not availabe
      return '外教在忙' unless tutor.state == 'available'

      # check if this student is available
      return '现在无法预约' unless self.state == 'matching'

      return '该外教暂不支持此类型计划' if tutor.level < plan_id.to_i

      request = self.requests.new(tutor_id: tutor.id, student_id: self.id,
                                  session_id: self.session_count,
                                  category: "prioritized", topic_id: topic_id, plan_id: plan_id)

      if tutor.state.eql? 'available' and request.save
        return 'success'
      else
        request.destroy
        return 'fail_database_failure'
      end
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


    # clean the verification code
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
