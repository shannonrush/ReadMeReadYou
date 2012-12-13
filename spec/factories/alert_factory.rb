FactoryGirl.define do
  factory :alert do
    association :user, :email=>"alert@rmry.com"
    message "This is an alert"
  end
end
