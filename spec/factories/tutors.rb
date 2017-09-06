FactoryGirl.define do
  factory :tutor, :class => Core::Tutor do
    sequence(:id) { |n| "#{n}" }
    sequence(:phoneNumber) { |n| "#{n}"*8 }
    country_code 1
    sequence(:name) { |n| "tutor#{n}" }
    sequence(:email) { |n| "tutor#{n}@example.com" }
    gender 'male'
    password "123456"
    picture "http://example.com"
    country 'canada'
    region 'ottawa'
    description 'sample description'
    balance 0.00
    device_token { random_token }
    level 1
    verification_code 4567
    factory :tutor_with_education do
      after(:create) do |tutor|
        create(:education, tutor: tutor)
      end
    end
  end

  factory :education, :class => Core::Education do
    sequence(:id) { |n| "#{n}" }
    school 'test schoold'
    major 'test major'
    degree 'bachelor'
    start_time { 1.week.ago }
    end_time { Time.now }
    tutor
  end
end

def random_token
  ('a'..'z').to_a.shuffle.join
end