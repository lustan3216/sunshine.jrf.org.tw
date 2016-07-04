# == Schema Information
#
# Table name: courts
#
#  id         :integer          not null, primary key
#  court_type :string
#  full_name  :string
#  name       :string
#  weight     :integer
#  created_at :datetime
#  updated_at :datetime
#  is_hidden  :boolean          default(TRUE)
#  code       :string
#  scrap_name :string
#

FactoryGirl.define do
  factory :court do
    court_type "法院"
    full_name "‎臺灣新北地方法院"
    name "‎新北地院"
    sequence(:scrap_name) { |n| "faker-court-#{n}" }
  end

  factory :court_for_params, class: Court do
    court_type "法院"
    full_name "‎臺灣"
    name "‎新北"
  end

end
