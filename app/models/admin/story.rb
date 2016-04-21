# == Schema Information
#
# Table name: stories
#
#  id            :integer          not null, primary key
#  court_id      :integer
#  main_judge_id :integer
#  story_type    :string
#  year          :integer
#  word_type     :string
#  number        :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Admin::Story < ::Story

end 
  
