FactoryGirl.define do
  factory :user, aliases:[:from,:to] do
    email {"user_#{rand(1000).to_s}@factory.com" }
    first "Shannon"
    last "Rush"
    password "password"
    password_confirmation "password"
    factory :user_no_after_create do
      after(:build) {|user| user.class.skip_callback(:create,:after,:send_welcome)}
    end
  end
end
