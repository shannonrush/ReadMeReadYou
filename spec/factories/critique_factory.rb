FactoryGirl.define do
  factory :critique do
    submission
    association :user, :email=>"critique@rmry.com"
    content "This is a critique"
    factory :critique_no_after_create do
      after(:build) {|critique| critique.class.skip_callback(:create,:after,:send_notification)}
    end
  end
end
