# == Schema Information
#
# Table name: stories
#
#  id               :integer          not null, primary key
#  court_id         :integer
#  main_judge_id    :integer
#  story_type       :string
#  year             :integer
#  word_type        :string
#  number           :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  defendant_names  :text
#  lawyer_names     :text
#  judges_names     :text
#  prosecutor_names :text
#

class Story < ActiveRecord::Base
  has_many :judge_stories
  has_many :judges, through: :judge_stories
  has_many :lawyer_stories
  has_many :lawyer, through: :lawyer_stories
  has_many :schedules
  has_many :verdicts
  belongs_to :main_judge, class_name: "Judge", foreign_key: "main_judge_id"
  belongs_to :court

  serialize :defendant_names, Array
  serialize :lawyer_names, Array
  serialize :judges_names, Array
  serialize :prosecutor_names, Array

  scope :newest, ->{ order("id DESC") }

  def identity
    "#{year}-#{word_type}-#{number}"
  end
end
