FactoryGirl.define do
  factory :message do
    association :from,email:"f@r.com"
    association :to,email:"t@r.com"
    message "The message"
    subject "The subject"
  end
end
