FactoryGirl.define do
  factory :appointment, :class => Core::Appointment do
    sequence(:id) { |n| "#{n}" }
    start_time { Time.now }
    end_time { Time.now + 10.minutes }
    student_rating 10
    tutor_rating 10
    student_feedback { ('a'..'z').to_a.shuffle.join }
    tutor_feedback { ('a'..'z').to_a.shuffle.join }
    plan_id 3
    tutor_earned 10.00
    amount 12.00
    student
    tutor
  end
end