module Core
  class Education < ApplicationRecord
    # ==========================================================================
    # EDUCATION MODEL ASSOCIATIONS
    # ==========================================================================
    belongs_to :tutor

    # ==========================================================================
    # TUTOR ATTRIBUTE OPERATION AND VALIDATION
    # ==========================================================================
    validates :degree, presence: true, 
              inclusion: { in: %w(associate bachelor master doctor) }
    validates :start_time, presence: true
    validates :end_time, presence: true
    validates :major, presence: true
    validates :school, presence: true

    # ==========================================================================
    # EDUCATION MODEL CALLBACKS
    # ==========================================================================
    # Initialize some fields to empty rather than null
    after_initialize :init

    # private functions
    private

    def init
      self.school ||= ''
      self.major ||= ''
      self.degree ||= ''
      self.start_time ||= ''
      self.end_time ||= ''
    end
  end
end