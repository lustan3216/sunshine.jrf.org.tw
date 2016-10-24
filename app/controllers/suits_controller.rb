# == Schema Information
#
# Table name: suits
#
#  id              :integer          not null, primary key
#  title           :string
#  summary         :text
#  content         :text
#  state           :string
#  pic             :string
#  suit_no         :integer
#  keyword         :string
#  created_at      :datetime
#  updated_at      :datetime
#  is_hidden       :boolean
#  procedure_count :integer          default(0)
#

class SuitsController < BaseController
  def index
    @suit_banners = SuitBanner.shown.order_by_weight
    @suits = Suit.shown.newest.page(params[:page]).per(9)
    set_meta(
      title: '司法案例面面觀',
      description: '不適任的法官、檢察官狀況有哪些？看看幾個案例，認識不適任的法官、檢察官！',
      keywords: '不適任法官,不適任檢察官,司法案例面面觀,司法恐龍,恐龍法官,恐龍檢察官',
      image: ActionController::Base.helpers.asset_path('hero-suits-index-M.png')
    )
  end

  def show
    @suit = Suit.find(params[:id])
    if @suit.is_hidden?
      not_found
    end
    @related_judges = @suit.judges
    @related_prosecutors = @suit.prosecutors
    @procedures = @suit.procedures.shown.sort_by_procedure_date
    @last_procedure = @procedures.is_done.first.present? ? @procedures.is_done.first : @procedures.first
    @related_suits = @suit.related_suits.shown.last(3)
    image = @suit.pic.present? ? @suit.pic.L_540.url : nil
    set_meta(
      title: @suit.title,
      description: "#{@suit.title} #{@suit.summary}",
      keywords: '不適任法官,不適任檢察官,司法恐龍案例,司法案例',
      image: image
    )
  end
end
