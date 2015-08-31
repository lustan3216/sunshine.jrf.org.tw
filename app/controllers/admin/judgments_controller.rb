class Admin::JudgmentsController < Admin::BaseController
  before_action :judgment
  before_action(except: [:index]){ add_crumb("重要判決列表", admin_judgments_path) }

  def index
    @judgments = Judgment.all.page(params[:page]).per(10)
    @admin_page_title = "重要判決列表"
    add_crumb @admin_page_title, "#"
  end

  def new
    @admin_page_title = "新增重要判決"
    add_crumb @admin_page_title, "#"
  end

  def edit
    @admin_page_title = "編輯重要判決"
    add_crumb @admin_page_title, "#"
  end

  def create
    if judgment.save
        respond_to do |f|
          f.html { redirect_to admin_judgments_path, flash: { success: "重要判決已新增" } }
          f.js { render }
        end
    else
      respond_to do |f|
        f.html { render :new, flash: { error: judgment.errors.full_messages } }
        f.js { render }
      end
    end
  end

  def update
    if judgment.update_attributes(judgment_params)
      redirect_to admin_judgments_path, flash: { success: "重要判決已修改" }
    else
      render :edit, flash: { error: judgment.errors.full_messages }
    end
  end

  def destroy
    if judgment.destroy
      redirect_to admin_judgments_path, flash: { success: "重要判決已刪除" }
    else
      redirect_to :back, flash: { error: judgment.errors.full_messages }
    end
  end

  private

  def judgment
    @judgment ||= params[:id] ? Admin::Judgment.find(params[:id]) : Admin::Judgment.new(judgment_params)
  end

  def judgment_params
    params.fetch(:admin_judgment, {}).permit(:court_id, :main_judge_id, :presiding_judge_id, :judge_no, :court_no, :judge_type, :judge_date, :reason, :content, :comment, :source, :source_link, :memo, judge_ids: [], prosecutor_ids: [])
  end
end