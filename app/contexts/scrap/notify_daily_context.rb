class Scrap::NotifyDailyContext < BaseContext
  SCRAP_MODELS = { court: '法院', judge: '法官', schedule: '庭期表', verdict: '判決書', rule: '裁決書' }.freeze

  after_perform :update_to_crawler_history
  after_perform :cleanup_redis_date
  after_perform :notify_abnormal_data

  class << self
    def perform
      new.perform
    end
  end

  def perform(scrap_models = SCRAP_MODELS)
    run_callbacks :perform do
      scrap_models.keys.map(&:to_s).each do |model|
        message = parse_message(model)
        SlackService.notify_scrap_daily_alert(message) if message
      end
    end
  end

  private

  def parse_message(model)
    class_object = Object.const_get(model.camelize)
    interval = redis_intervel(model).value
    count = redis_count(model).value
    if interval
      message = "\n#{SCRAP_MODELS[model.to_sym]}爬蟲報告 :\n今日爬取時間參數 : #{interval}\n今日爬取總數 : #{count} 筆\n資料庫目前總數 : #{class_object.count} 筆"
      return message
    else
      return nil
    end
  end

  def update_to_crawler_history
    @crawler_history = CrawlerHistory.find_or_create_by(crawler_on: Time.zone.today)
    SCRAP_MODELS.keys.map(&:to_s).each do |model|
      @crawler_history.assign_attributes("#{model}s_count": redis_count(model).value)
    end
    @crawler_history.save
  end

  def cleanup_redis_date
    SCRAP_MODELS.keys.map(&:to_s).each do |model|
      redis_intervel(model).delete
      redis_count(model).value = 0
    end
  end

  def notify_abnormal_data
    Scrap::NotifyAbnormalDataContext.new(@crawler_history).perform
  end

  def redis_intervel(model)
    if model == ('verdict' || 'rule')
      Redis::Value.new('daily_scrap_referee_intervel')
    else
      Redis::Value.new("daily_scrap_#{model}_intervel")
    end
  end

  def redis_count(model)
    Redis::Counter.new("daily_scrap_#{model}_count")
  end
end
