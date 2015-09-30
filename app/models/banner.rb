# == Schema Information
#
# Table name: banners
#
#  id         :integer          not null, primary key
#  pic_l      :string(255)
#  pic_m      :string(255)
#  pic_s      :string(255)
#  weight     :integer
#  is_hidden  :boolean
#  created_at :datetime
#  updated_at :datetime
#

class Banner < ActiveRecord::Base
  mount_uploader :pic_l, BannerPicLUploader
  mount_uploader :pic_m, BannerPicMUploader
  mount_uploader :pic_s, BannerPicSUploader

  scope :order_by_weight, ->{ order("weight DESC, id DESC") }
  scope :published, ->{ where(:is_hidden => [false,nil]) }
end