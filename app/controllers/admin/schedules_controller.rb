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

class Admin::SchedulesController < Admin::BaseController
   before_action :find_story_by_ransack_search, :only => [:index]

  def index
    @search = Schedule.all.newest.ransack(params[:q])
    @schedules = @search.result.includes(:court, :story).page(params[:page]).per(20)
    @admin_page_title = @story ? "案件 #{@story.identity} 的庭期表" : "庭期表列表"
    add_crumb @admin_page_title, "#"
  end

  private
  
  def find_story_by_ransack_search
    return @story = Story.find(params[:q][:story_id_eq]) if params[:q].try { |q| q.include?(:story_id_eq) }
  end  

end
