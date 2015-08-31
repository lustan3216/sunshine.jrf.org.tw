class Admin::SuitsController < Admin::BaseController
  before_action :suit
  before_action(except: [:index]){ add_crumb("評鑑資料-案例列表", admin_suits_path) }

  def index
    @suits = Suit.all.page(params[:page]).per(10)
    @admin_page_title = "評鑑資料-案例列表"
    add_crumb @admin_page_title, "#"
  end

  def show
    @admin_page_title = "評鑑資料-案例 - #{suit.title} 的詳細資料"
    add_crumb @admin_page_title, "#"
  end

  def new
    @admin_page_title = "新增評鑑資料-案例"
    add_crumb @admin_page_title, "#"
  end

  def edit
    @admin_page_title = "編輯評鑑資料-案例"
    add_crumb @admin_page_title, "#"
  end

  def create
    if suit.save
        respond_to do |f|
          f.html { redirect_to admin_suits_path, flash: { success: "評鑑資料-案例已新增" } }
          f.js { render }
        end
    else
      respond_to do |f|
        f.html { render :new, flash: { error: suit.errors.full_messages } }
        f.js { render }
      end
    end
  end

  def update
    if suit.update_attributes(suit_params)
      redirect_to admin_suits_path, flash: { success: "評鑑資料-案例已修改" }
    else
      render :edit, flash: { error: suit.errors.full_messages }
    end
  end

  def destroy
    if suit.destroy
      redirect_to admin_suits_path, flash: { success: "評鑑資料-案例已刪除" }
    else
      redirect_to :back, flash: { error: suit.errors.full_messages }
    end
  end

  private

  def suit
    @suit ||= params[:id] ? Admin::Suit.find(params[:id]) : Admin::Suit.new(suit_params)
  end

  def suit_params
    params.fetch(:admin_suit, {}).permit(:title, :summary, :content, :state, :pic, :suit_no, :keyword, judge_ids: [], prosecutor_ids: [])
  end
end