# == Schema Information
#
# Table name: prosecutors_offices
#
#  id         :integer          not null, primary key
#  full_name  :string
#  name       :string
#  court_id   :integer
#  is_hidden  :boolean          default(TRUE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ProsecutorsOffice < ActiveRecord::Base
  include HiddenOrNot
  has_many :prosecutors
  belongs_to :court

  scope :newest, -> { order('id DESC') }

  validates :full_name, :name, uniqueness: true
  validates :court, :full_name, presence: true
end
