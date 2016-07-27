class Lawyer::VerdictScoreUpdateContext < BaseContext
  PERMITS = [:quality_score, :note, :appeal_judge].freeze

  before_perform :check_quality_score
  before_perform :assign_attribute

  def initialize(lawyer, verdict_score)
    @lawyer = lawyer
    @verdict_score = verdict_score
  end

  def perform(params)
    @params = permit_params(params[:verdict_score] || params, PERMITS)
    run_callbacks :perform do
      return add_error(:data_update_fail, "更新失敗") unless @verdict_score.save
      @verdict_score
    end
  end

  private

  def check_quality_score
    return add_error(:data_blank, "裁判品質為必填") unless @params[:quality_score].present?
  end

  def assign_attribute
    @verdict_score.assign_attributes(@params)
  end
end
