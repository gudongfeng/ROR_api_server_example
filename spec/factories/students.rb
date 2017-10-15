FactoryGirl.define do
  factory :student, :class => Core::Student do
    sequence(:id) { |n| "#{n}" }
    sequence(:phoneNumber) { |n| "#{n}"*8 }
    country_code 1
    sequence(:name) { |n| "student#{n}" }
    sequence(:email) { |n| "student#{n}@example.com" }
    gender 'male'
    password "123456"
    picture "http://example.com"
    verification_code 4567
  end
end