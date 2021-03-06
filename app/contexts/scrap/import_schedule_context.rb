class Scrap::ImportScheduleContext < BaseContext
  before_perform  :find_court
  before_perform  :build_data
  before_perform  :get_branch_judge
  before_perform  :find_or_create_story
  after_perform   :update_story_is_pronounced
  after_perform   :update_story_pronounced_on
  after_perform   :record_count_to_daily_notify
  after_perform   :alert_new_story_type
  after_perform   :log_branch_judge_not_found

  class << self
    def perform(court_code, hash)
      new(court_code).perform(hash)
    end
  end

  def initialize(court_code)
    @court_code = court_code
    @crawler_history = CrawlerHistory.find_or_create_by(crawler_on: Time.zone.today)
  end

  def perform(hash)
    @hash = hash
    run_callbacks :perform do
      @schedule = @story.schedules.find_or_create_by(court: @court, branch_name: @branch_name, start_on: @start_on, start_at: @start_at, branch_judge: @branch_judge, courtroom: @courtroom)
    end
  end

  private

  def find_court
    @court = Court.find_by(code: @court_code)
  end

  def build_data
    @is_pronounced = @hash[:is_pronounced]
    @story_type   = @hash[:story_type]
    @year         = @hash[:year]
    @word_type    = @hash[:word_type]
    @number       = @hash[:number]
    @start_on     = @hash[:start_on]
    @start_at     = @hash[:start_at]
    @branch_name  = @hash[:branch_name]
    @courtroom    = @hash[:courtroom]
  end

  def get_branch_judge
    branches = @court.branches.current.where(name: @branch_name)
    branches = branches.where('chamber_name LIKE ? ', "%#{@story_type}%") if branches.map(&:judge_id).uniq.count > 1
    @branch_judge = branches.first ? branches.first.judge : nil
  end

  def find_or_create_story
    @story = @court.stories.find_or_create_by(story_type: @story_type, year: @year, word_type: @word_type, number: @number)
  end

  def update_story_is_pronounced
    @story.update_attributes(is_pronounced: @is_pronounced) if @is_pronounced
  end

  def update_story_pronounced_on
    unless @story.pronounced_on
      @story.update_attributes(pronounced_on: @start_on) if @is_pronounced
    end
  end

  def record_count_to_daily_notify
    Redis::Counter.new('daily_scrap_schedule_count').increment
  end

  def alert_new_story_type
    SlackService.notify_analysis_schedule_alert("取得新的案件類別 : #{@story_type}") if @story_type.present? && !StoryTypes.list.include?(@story_type)
  end

  def log_branch_judge_not_found
    Logs::AddCrawlerError.add_schedule_error(@crawler_history, @schedule, :parse_branch_judge_empty, "股別關聯主審法官 關聯失敗, 關聯資訊 : #{@hash}") unless @branch_judge
  end
end
