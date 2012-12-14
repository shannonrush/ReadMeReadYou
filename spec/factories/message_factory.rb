FactoryGirl.define do
  factory :message do
    association :from
    association :to
    message "The message"
    subject "The subject"
  end
end
