# == Schema Information
#
# Table name: schedules
#
#  id          :integer          not null, primary key
#  story_id    :integer
#  court_id    :integer
#  branch_name :string
#  date        :date
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Admin::Schedule < ::Schedule
  belongs_to :story
  belongs_to :court

end