require 'rails_helper'

RSpec.describe Search::VerdictsController, type: :request do
  include_context 'create_data_for_request'
  let!(:verdict) { create :verdict, story: story }

  describe '#show' do
    let(:url) { URI.encode("/search/#{code}/#{story.identity}/verdict") }
    before { get url }
    it { expect(response).to be_success }
    it { expect(response.body).to match(verdict.reason) }
  end
end
