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
#  is_hidden  :boolean
#

class Admin::Court < ::Court
  has_many :judgments, class_name: "Admin::Judgment"

  validates_presence_of :court_type, :full_name
  validates_uniqueness_of :full_name, :name

  COURT_TYPES = [
    "法院",
    "檢察署"
  ]

	def self.judges
    where(court_type: "法院")
  end

  def self.prosecutors
    where(court_type: "檢察署")
  end

end
