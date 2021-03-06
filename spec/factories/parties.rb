# == Schema Information
#
# Table name: parties
#
#  id                       :integer          not null, primary key
#  name                     :string           not null
#  identify_number          :string           not null
#  phone_number             :string
#  encrypted_password       :string           default(""), not null
#  reset_password_token     :string
#  reset_password_sent_at   :datetime
#  remember_created_at      :datetime
#  sign_in_count            :integer          default(0), not null
#  current_sign_in_at       :datetime
#  last_sign_in_at          :datetime
#  current_sign_in_ip       :string
#  last_sign_in_ip          :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  email                    :string
#  unconfirmed_email        :string
#  confirmed_at             :datetime
#  confirmation_token       :string
#  confirmation_sent_at     :datetime
#  imposter                 :boolean          default(FALSE)
#  imposter_identify_number :string
#  phone_confirmed_at       :datetime
#  unconfirmed_phone        :string
#

FactoryGirl.define do
  factory :party do
    sequence(:name) { |n| "當事人 - #{n}" }
    password '12321313213'
    sequence(:identify_number) { "A#{rand(100_000_000..299_999_999)}" }
    sequence(:phone_number) { "09#{rand(1..99_999_999).to_s.rjust(8, '0')}" }
    sequence(:email) { |n| "#{n}aaoo@gmail.com" }
    trait :with_unconfirmed_email do
      sequence(:unconfirmed_email) { |n| "#{n}aaoogg@gmail.com" }
    end

    trait :already_confirmed do
      confirmed_at Time.now
    end

    trait :with_confirmation_token do
      sequence(:confirmation_token) { |n| "#{n}aaooggdw" }
    end

    trait :with_unconfirmed_phone do
      sequence(:unconfirmed_phone) { "09#{rand(1..99_999_999).to_s.rjust(8, '0')}" }
    end

    trait :without_phone_number do
      phone_number nil
    end
  end

  factory :party_for_create, class: Party do
    sequence(:name) { |n| "當事人 - #{n}" }
    password '12321313213'
    password_confirmation '12321313213'
    sequence(:identify_number) { |_n| "A#{rand(100_000_000..299_999_999)}" }
    sequence(:phone_number) { |_n| "09#{rand(1..99_999_999).to_s.rjust(8, '0')}" }
  end
end
