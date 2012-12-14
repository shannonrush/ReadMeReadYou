FactoryGirl.define do
  factory :comment do
    critique
    association :user, :email => "comment@rmry.com"
    content "Nice critique"
    
  end
end
