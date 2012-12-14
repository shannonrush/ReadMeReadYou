FactoryGirl.define do
  factory :critique do
    submission
    user
    content "This is a critique"
    factory :critique_no_after_create do
      after(:build) {|critique| critique.class.skip_callback(:create,:after,:send_notification)}
      after(:build) {|critique| critique.class.skip_callback(:create,:after,:alert_for_new_critique)}
    end
  end
end
