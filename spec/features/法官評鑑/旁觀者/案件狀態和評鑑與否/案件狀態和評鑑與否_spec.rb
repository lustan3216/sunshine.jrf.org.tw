require 'rails_helper'
feature '法官評鑑 - 旁觀者', type: :feature, js: true do
  let!(:court_observer) { create :court_observer }
  let!(:schedule) { create :schedule, :court_with_judge }
  let(:story) { schedule.story }
  before { signin_court_observer(email: court_observer.email) }

  feature '案件的狀態和評鑑與否' do
    Scenario '案件尚未抓到判決書 (即沒有判決日)' do
      before { story.update_attributes(is_adjudged: false) }

      Given '案件無宣判日' do
        When '進行新增開庭評鑑' do
          before { court_observer_run_schedule_score_flow(schedule) }
          Then '成功新增開庭評鑑' do
            expect(page).to have_content('感謝您的評鑑')
          end
        end

        When '進行編輯開庭評鑑' do
          before { court_observer_run_schedule_score_flow(schedule) }
          before { court_observer_edit_schedule_score }
          before { click_button '更新評鑑' }
          Then '成功編輯開庭評鑑' do
            expect(page).to have_content('感謝您的評鑑')
          end
        end

        When '進行新增判決評鑑' do
          before { visit(new_court_observer_score_verdict_path) }
          Then '無法進行' do
            expect(page).to have_content('此頁面不存在')
          end
        end
      end

      Given '案件的宣判日在未來' do
        before { story.update_attributes(pronounced_on: Time.zone.today + 1.day) }
        When '進行新增開庭評鑑' do
          before { court_observer_run_schedule_score_flow(schedule) }
          Then '成功新增開庭評鑑' do
            expect(page).to have_content('感謝您的評鑑')
          end
        end

        When '進行編輯開庭評鑑' do
          before { court_observer_run_schedule_score_flow(schedule) }
          before { court_observer_edit_schedule_score }
          before { click_button '更新評鑑' }
          Then '成功編輯開庭評鑑' do
            expect(page).to have_content('感謝您的評鑑')
          end
        end

        When '進行新增判決評鑑' do
          before { visit(new_court_observer_score_verdict_path) }
          Then '無法進行' do
            expect(page).to have_content('此頁面不存在')
          end
        end
      end

      Given '案件的宣判日在過去' do
        before { story.update_attributes(pronounced_on: Time.zone.today - 1.day) }
        When '進行新增開庭評鑑' do
          before { visit(input_info_court_observer_score_schedules_path) }
          before { court_observer_input_info_schedule_score(story) }
          Then '無法進行' do
            expect(page).to have_content('案件已宣判, 無法評鑑')
          end
        end

        When '進行新增判決評鑑' do
          before { visit(new_court_observer_score_verdict_path) }
          Then '無法進行' do
            expect(page).to have_content('此頁面不存在')
          end
        end
      end
    end

    Scenario '案件已抓到判決書，且宣判日在過去或當天' do
      before { story.update_attributes(is_adjudged: true, is_pronounced: true) }

      Given '判決日與宣判日在當天' do
        before { story.update_attributes(adjudged_on: Time.zone.today, is_adjudged: true) }
        before { story.update_attributes(pronounced_on: Time.zone.today) }
        When '進行新增開庭評鑑' do
          before { visit(input_info_court_observer_score_schedules_path) }
          before { court_observer_input_info_schedule_score(story) }
          Then '無法進行' do
            expect(page).to have_content('已有判決書, 不可評鑑開庭')
          end
        end

        When '進行新增判決評鑑' do
          before { court_observer_run_verdict_score_flow }
          Then '無法進行' do
            expect(page).to have_content('此頁面不存在')
          end
        end
      end

      Given '判決日在三個月內的過去，宣判日在三個月外的過去' do
        before { story.update_attributes(adjudged_on: Time.zone.today - 2.months) }
        before { story.update_attributes(pronounced_on: Time.zone.today - 4.months) }
        When '進行新增開庭評鑑' do
          before { visit(input_info_court_observer_score_schedules_path) }
          before { court_observer_input_info_schedule_score(story) }
          Then '無法進行' do
            expect(page).to have_content('案件已宣判, 無法評鑑')
          end
        end

        When '進行新增判決評鑑' do
          before { court_observer_run_verdict_score_flow }
          Then '無法進行' do
            expect(page).to have_content('此頁面不存在')
          end
        end
      end

      Given '判決日在三個月外的過去，宣判日在三個月外的過去' do
        before { story.update_attributes(adjudged_on: Time.zone.today - 4.months) }
        before { story.update_attributes(pronounced_on: Time.zone.today - 4.months) }
        When '進行新增開庭評鑑' do
          before { visit(input_info_court_observer_score_schedules_path) }
          before { court_observer_input_info_schedule_score(story) }
          Then '無法進行' do
            expect(page).to have_content('案件已宣判, 無法評鑑')
          end
        end

        When '進行新增判決評鑑' do
          before { visit(new_court_observer_score_verdict_path) }
          Then '無法進行' do
            expect(page).to have_content('此頁面不存在')
          end
        end
      end
    end
  end
end
