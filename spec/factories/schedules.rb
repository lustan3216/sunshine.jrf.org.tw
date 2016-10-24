# == Schema Information
#
# Table name: schedules
#
#  id              :integer          not null, primary key
#  story_id        :integer
#  court_id        :integer
#  branch_name     :string
#  start_on        :date
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  branch_judge_id :integer
#  courtroom       :string
#  start_at        :datetime
#

FactoryGirl.define do
  factory :schedule do
    branch_name '股別名稱'
    start_on { Date.current }
    start_at { Date.current }
    courtroom '鋼鐵教廷'
    court { create :court }
    story { create :story }

    trait :with_branch_judge do
      branch_judge { create :judge }
    end

    trait :date_is_tomorrow do
      start_on { Date.tomorrow }
    end

    trait :date_is_yesterday do
      start_on { Date.yesterday }
    end
  end

end
