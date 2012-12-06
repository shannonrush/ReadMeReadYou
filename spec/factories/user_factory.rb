FactoryGirl.define do
  factory :user do
    email "shannon@readmereadyou.com"
    first "Shannon"
    last "Rush"
    password "password"
    password_confirmation "password"
  end
end
