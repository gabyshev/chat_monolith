FactoryGirl.define do
  factory :message do
    body 'Hello'
    conversation
    user
  end
end
