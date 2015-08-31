# == Schema Information
#
# Table name: awards
#
#  id          :integer          not null, primary key
#  profile_id  :integer
#  award_type  :string(255)
#  unit        :string(255)
#  content     :text
#  publish_at  :date
#  source      :text
#  source_link :string(255)
#  origin_desc :text
#  memo        :text
#  created_at  :datetime
#  updated_at  :datetime
#

class Award < ActiveRecord::Base
  belongs_to :profile
end