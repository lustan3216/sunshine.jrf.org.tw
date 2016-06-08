# == Schema Information
#
# Table name: lawyers
#
#  id                     :integer          not null, primary key
#  name                   :string           not null
#  current                :string
#  avatar                 :string
#  gender                 :string
#  birth_year             :integer
#  memo                   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  email                  :string           not null
#  encrypted_password     :string           default("")
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  last_sign_in_at        :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  confirmation_token     :string
#  confirmation_sent_at   :datetime
#  confirmed_at           :datetime
#  unconfirmed_email      :string
#

FactoryGirl.define do
  factory :lawyer do
    name "lawyer"
    sequence(:email) { |n| "bystander-#{n}@test.com"}

    trait :with_avatar do
      avatar File.open "#{Rails.root}/spec/fixtures/person_avatar/people-1.jpg"
    end

    trait :with_password_and_confirmed do
      password "123123123"
      confirmed_at Time.now
    end

    trait :with_gender do
      gender "男"
    end

    trait :with_verdict do
      after(:create) do |lawyer|
        FactoryGirl.create :verdict_relation, person: lawyer, verdict: FactoryGirl.create(:verdict)
      end
    end
  end

  factory :empty_name_for_lawyer, class: Lawyer do
    name ""
    email "aron@example.com"
  end

  factory :empty_email_for_lawyer, class: Lawyer do
    name "aron"
    email ""
  end

end
