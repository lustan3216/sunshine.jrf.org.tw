require "rails_helper"

describe CourtObserver::ChangeEmailContext do
  let!(:court_observer) { FactoryGirl.create :court_observer }

  describe "perform" do
    context "success" do
      let(:params) { { email: "h2312@gmail.com", current_password: "123123123" } }
      subject { described_class.new(court_observer) }

      it { expect { subject.perform(params) }.to change { court_observer.reload.unconfirmed_email } }
    end

    context "update the same email" do
      let(:params) { { email: court_observer.email, current_password: "123123123" } }
      subject { described_class.new(court_observer) }

      it { expect { subject.perform(params) }.not_to change { court_observer.reload.unconfirmed_email } }
    end

    context "update other's unconfirmed_email" do
      let!(:court_observer2) { FactoryGirl.create :court_observer, :with_unconfirmed_email }
      let(:params) { { email: court_observer2.unconfirmed_email, current_password: "123123123" } }
      subject { described_class.new(court_observer) }

      it { expect { subject.perform(params) }.not_to change { court_observer.reload.unconfirmed_email } }
    end

    context "empty password" do
      let(:params) { { email: court_observer.email, current_password: "" } }
      subject { described_class.new(court_observer) }

      it { expect { subject.perform(params) }.not_to change { court_observer.reload.unconfirmed_email } }
    end
  end

end