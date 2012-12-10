FactoryGirl.define do
  factory :user do
    email "shannon@readmereadyou.com"
    first "Shannon"
    last "Rush"
    password "password"
    password_confirmation "password"
    factory :user_no_after_create do
      after(:build) {|user| user.class.skip_callback(:create,:after,:send_welcome)}
    end
  end
end
