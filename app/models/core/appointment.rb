module Core
  class Appointment < ApplicationRecord

    # ==========================================================================
    # STUDENT MODEL ASSOCIATIONS
    # ==========================================================================
    belongs_to :tutor
    belongs_to :student
    belongs_to :discount

    # ==========================================================================
    # APPOINTMENT ATTRIBUTE OPERATION AND VALIDATION
    # =========================================================================
    validates :start_time, presence: true
    validates :end_time, presence: true
    validates :student_rating, inclusion: { in: 1..5 }
    validates :tutor_rating, inclusion: { in: 1..10 }
    validates :plan_id, inclusion: { in: 1..3 }

    # ==========================================================================
    # STUDENT FUNCTIONS
    # ===========================================================================
    # (updated)
    def to_json(options={})
      options[:except] ||= [:created_at, :updated_at]
      super(options)
    end

    def student_all_appointment_to_json
      options={}
      options[:only] = [:pay_state, :start_time, :end_time,
                        :amount, :tutor_feedback, :tutor_rating,
                        :student_call_duration]
      self.as_json options
    end
  end
end
