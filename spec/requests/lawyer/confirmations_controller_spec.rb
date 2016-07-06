require "rails_helper"

RSpec.describe Lawyer::ConfirmationsController, type: :request do
  let!(:lawyer) { FactoryGirl.create :lawyer }

  describe "#show" do
    context "validate token" do
      context "need set password" do
        before { get "/lawyer/confirmation", confirmation_token: lawyer.confirmation_token }
        it { expect(response).to be_redirect }
      end

      context "only confirm" do
        let!(:lawyer) { FactoryGirl.create :lawyer, :with_password }
        before { get "/lawyer/confirmation", confirmation_token: lawyer.confirmation_token }
        it { expect(response).to redirect_to("/lawyer/sign_in") }
      end
    end

    context "invalidate token" do
      before { get "/lawyer/confirmation", confirmation_token: "wwwwwww" }
      it { expect(response).to redirect_to("/lawyer/sign_in")  }
    end
  end
end