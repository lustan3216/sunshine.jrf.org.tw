# == Schema Information
#
# Table name: judges
#
#  id                 :integer          not null, primary key
#  name               :string
#  current_court_id   :integer
#  avatar             :string
#  gender             :string
#  gender_source      :string
#  birth_year         :integer
#  birth_year_source  :string
#  stage              :integer
#  stage_source       :string
#  appointment        :string
#  appointment_source :string
#  memo               :string
#  is_active          :boolean
#  is_hidden          :boolean
#  punishments_count  :integer          default(0)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class Judge < ActiveRecord::Base
  has_many :judge_verdicts
  has_many :verdicts, through: :judge_verdicts
  has_many :branches
  has_many :main_judge_stories, class_name: "Story", foreign_key: "main_judge_id"
  has_many :main_judge_verdicts, class_name: "Verdict", foreign_key: "main_judge_id"
  belongs_to :court, foreign_key: :current_court_id
  has_many :schedules, foreign_key: "branch_judge_id"
  has_many :story_relations, as: :people

  mount_uploader :avatar, ProfileAvatarUploader

end
