FactoryGirl.define do
  factory :user, aliases: [:sender, :recipient] do
    first_name 'John'
    last_name 'Black'
    sequence(:email) { |n| "email_#{n}@test.com" }
    password '123123'
  end
end
