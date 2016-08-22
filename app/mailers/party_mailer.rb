class PartyMailer < ApplicationMailer
  def story_before_judge_notice(story_id, party_id)
    @story = Story.find(story_id)
    @party = Party.find(party_id)
    @court_wording = "#{@story.court.full_name}#{@story.year}年#{@story.word_type}字第#{@story.number}號"
    @date = @story.schedules.last.date
    mail(to: @party.email, subject: @court_wording + "開庭通知")
  end

  def story_after_judge_notice(story_id, party_id)
    @story = Story.find(story_id)
    @party = Party.find(party_id)
    @court_wording = "#{@story.court.full_name}#{@story.year}年#{@story.word_type}字第#{@story.number}號"
    mail(to: @party.email, subject: @court_wording + "開庭完畢，邀請您提供您的寶貴意見！")
  end
end
