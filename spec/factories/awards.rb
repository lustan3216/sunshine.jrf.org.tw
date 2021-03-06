# == Schema Information
#
# Table name: awards
#
#  id          :integer          not null, primary key
#  profile_id  :integer
#  award_type  :string
#  unit        :string
#  content     :text
#  publish_at  :date
#  source      :text
#  source_link :text
#  origin_desc :text
#  memo        :text
#  created_at  :datetime
#  updated_at  :datetime
#  is_hidden   :boolean
#  owner_id    :integer
#  owner_type  :string
#

FactoryGirl.define do
  factory :award do
    owner do
      create :judge
    end
    award_type '嘉獎一次'
    unit '司法院'
    publish_at Time.zone.today
  end

end
