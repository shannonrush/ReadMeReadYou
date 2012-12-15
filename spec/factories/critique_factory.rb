FactoryGirl.define do
  factory :critique do
    submission
    user
    content "This is a critique"
  end
end
