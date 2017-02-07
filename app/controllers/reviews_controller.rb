class ReviewsController < BaseController
  before_action :find_owner

  def index
    if @owner.is_hidden?
      not_found
    end
    @reviews = @owner.reviews.shown.had_title.order_by_publish_at.page(params[:page]).per(12)
    @newest_award = @owner.awards.shown.order_by_publish_at.first
    @newest_punishments = @owner.punishments.shown.order_by_relevant_date.first(3)
    @newest_reviews = @reviews.shown.first(3)
    set_meta(
      title: { name: @owner.name },
      description: { name: @owner.name },
      keywords: { name: @owner.name },
      image: ActionController::Base.helpers.asset_path('hero-profiles-show-M.png')
    )
  end

  private

  def find_owner
    @owner_class = Object.const_get(request.env['PATH_INFO'][/\w+/].singularize.camelize)
    @owner = @owner_class.find(owner_id)
  end

  def owner_id
    params["#{@owner_class.to_s.downcase.demodulize}_id"]
  end
end
