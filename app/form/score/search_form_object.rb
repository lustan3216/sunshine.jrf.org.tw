class Score::SearchFormObject < BaseFormObject
  PARAMS = [:score_type_eq, :judge_id_eq, :story_id_eq, :rater_type_eq, :rater_id_eq, :created_at_gteq, :created_at_lteq].freeze
  attr_accessor(*PARAMS)

  def initialize(params = {})
    @params = params
    assign_value
  end

  def result
    schedule_scores_result + verdict_scores_result
  end

  private

  def assign_value
    self.score_type_eq = @params[:score_type_eq]
    self.judge_id_eq = @params[:judge_id_eq]
    self.story_id_eq = @params[:story_id_eq]
    self.rater_type_eq = @params[:rater_type_eq]
    self.rater_id_eq = @params[:rater_id_eq]
    self.created_at_gteq = @params[:created_at_gteq]
    self.created_at_lteq = @params[:created_at_lteq]
  end

  def only_schedule_score?
    score_type_eq == 'ScheduleScore' || judge_id_eq.present?
  end

  def only_verdict_score?
    score_type_eq == 'VerdictScore'
  end

  def schedule_scores_result
    only_verdict_score? ? [] : ScheduleScore.ransack(@params).result.includes(:story, :schedule_rater)
  end

  def verdict_scores_result
    only_schedule_score? ? [] : VerdictScore.ransack(@params).result.includes(:story, :verdict_rater)
  end
end
