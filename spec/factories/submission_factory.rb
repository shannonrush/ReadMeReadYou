FactoryGirl.define do
  factory :submission do
    title "The Story"
    genre "Horror"
    notes "These are author notes"
    content "This is the story"
    user
  end
end
