require 'rails_helper'

RSpec.describe Admin::VerdictsController do
  before { signin_user }

  describe '#index' do
    let!(:verdict) { create :verdict }

    context 'render success' do
      before { get '/admin/verdicts' }
      it { expect(response).to be_success }
    end

    context 'search the adjudged_on' do
      before { get '/admin/verdicts', q: { adjudged_on_eq: verdict.adjudged_on } }
      it { expect(response.body).to match(verdict.story.court.full_name) }
    end

    context 'search unexist_judges_names' do
      let!(:verdict1) { create :verdict, judges_names: ['xxxx'] }
      before { get '/admin/verdicts', q: { unexist_judges_names: 1 } }
      it { expect(response.body).to match(verdict.story.court.full_name) }
      it { expect(response.body).not_to match(verdict1.judges_names.first) }
    end
  end

  describe '#show' do
    let!(:verdict) { create :verdict }
    before { get "/admin/verdicts/#{verdict.id}" }

    it { expect(response).to be_success }
  end

  describe '#download_file' do
    let!(:verdict) { create :verdict, :with_file }

    context 'search the content of verdicts' do
      before { get "/admin/verdicts/#{verdict.id}/download_file" }
      it { expect(response).to be_success }
    end
  end
end
