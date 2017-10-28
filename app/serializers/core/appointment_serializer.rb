class Core::AppointmentSerializer < ActiveModel::Serializer
  attributes :id, :start_time, :end_time, :tutor_id, :student_id, :student_rating,
    :student_feedback, :tutor_rating, :tutor_feedback, :pay_state, :plan_id, :amount,
    :tutor_earned, :discount_id
end
