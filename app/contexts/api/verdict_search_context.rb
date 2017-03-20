class Api::VerdictSearchContext < BaseContext
  before_perform :find_court
  before_perform :find_story

  def initialize(story_identity)
    @court_code, @year, @word, @number = story_identity.split('-')
  end

  def perform
    run_callbacks :perform do
      return add_error(:verdicts_not_exist) unless @story.verdict
      @story.verdict
    end
  end

  private

  def find_court
    @court = Court.find_by(code: @court_code)
    return add_error(:court_not_found, '該法院代號不存在') unless @court
  end

  def find_story
    @story = Story.find_by(year: @year, word_type: @word, number: @number, court: @court)
    return add_error(:story_not_found) unless @story
  end

end
