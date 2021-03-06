class Scrap::GetRefereesByCourtContext < BaseContext
  INDEX_URI = 'http://jirs.judicial.gov.tw/FJUD/FJUDQRY01_1.aspx'.freeze

  before_perform :get_story_types

  class << self
    def perform(court, start_date, end_date)
      new(court, start_date, end_date).perform
    end
  end

  def initialize(court, start_date, end_date)
    @court = court
    @start_date = start_date
    @end_date = end_date
    @crawler_history = CrawlerHistory.find_or_create_by(crawler_on: Time.zone.today)
  end

  def perform
    run_callbacks :perform do
      @story_types.each do |type|
        Scrap::GetRefereesTotalResultContext.delay(retry: false, queue: 'crawler_referee').perform(court: @court, type: type, start_date: @start_date, end_date: @end_date)
      end
    end
  end

  private

  def get_story_types
    response_data = Mechanize.new.get(INDEX_URI)
    response_data = Nokogiri::HTML(response_data.body)
    @story_types = response_data.css("input[type='radio']").map { |row| row.attribute('value').value }.uniq
  rescue
    request_retry(key: "#{INDEX_URI} / #{Time.zone.today}")
  end

  def request_retry(key:)
    redis_object = Redis::Counter.new(key, expiration: 1.day)
    if redis_object.value < 12
      self.class.delay_for(1.hour, queue: 'crawler_referee').perform(@court, @start_date, @end_date)
      redis_object.incr
    else
      Logs::AddCrawlerError.parse_referee_data_error(@crawler_history, :crawler_failed, "取得裁判書類別失敗, 來源網址:#{INDEX_URI}")
    end
    false
  end
end
