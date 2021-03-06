require 'rails_helper'
feature '法官評鑑 - 旁觀者', type: :feature, js: true do
  let!(:court_observer) { create :court_observer }
  let!(:court) { create :court }
  let!(:story) { create :story, court: court }
  let!(:judge) { create :judge, court: court }
  let!(:schedule) { create :schedule, court: court, story: story }
  before { signin_court_observer(email: court_observer.email) }

  feature '開庭評鑑' do
    feature '評分項驗證' do
      Scenario '開庭評鑑流程中，正在輸入評分項的頁面' do
        before { visit(input_info_court_observer_score_schedules_path) }
        before { court_observer_input_info_schedule_score(story) }
        before { court_observer_input_date_schedule_score(schedule) }
        before { court_observer_input_judge_schedule_score(judge) }

        Given '旁觀者 選擇「開庭態度」評分' do
          before { 3.times.each_with_index { |i| choose("schedule_score_score_1_#{i + 1}_20") } }
          When '送出' do
            before { click_button '送出評鑑' }
            Then '顯示感謝頁面' do
              expect(page).to have_content('感謝您的評鑑')
            end
          end
        end

        Given '旁觀者 未選擇「開庭態度」評分' do
          When '送出' do
            before { click_button '送出評鑑' }
            Then '顯示錯誤訊息，頁面仍保留原始輸入資訊' do
              expect(find_field('schedule_score_score_1_1_20')).not_to be_checked
              expect(page).to have_content('開庭態度分數為必填')
            end
          end
        end
      end
    end
  end
end
