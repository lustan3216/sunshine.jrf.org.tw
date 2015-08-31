# == Schema Information
#
# Table name: courts
#
#  id         :integer          not null, primary key
#  court_type :string(255)
#  full_name  :string(255)
#  name       :string(255)
#  weight     :integer
#  created_at :datetime
#  updated_at :datetime
#

class Admin::Court < ::Court
  has_many :judgments, :class_name => "Admin::Judgment"

  validates_presence_of :court_type, :full_name

  COURT_TYPES = [
    "法院",
    "檢察署"
  ]

end