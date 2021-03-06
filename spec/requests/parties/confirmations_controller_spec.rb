require 'rails_helper'

RSpec.describe Parties::ConfirmationsController, type: :request do
  let!(:party) { create :party, confirmation_token: 'imtoken' }

  describe '#show' do
    context 'validate token' do
      subject { get '/party/confirmation', confirmation_token: party.confirmation_token }
      it { expect(subject).to redirect_to('/party/sign_in') }
      it { expect { subject }.to change { Party.last.confirmed? } }
    end

    context 'already sign in' do
      before { signin_party(party) }
      subject { get '/party/confirmation', confirmation_token: party.confirmation_token }

      it { expect(subject).to redirect_to('/party/profile') }
      it { expect { subject }.to change { party.reload.confirmed? } }
    end

    context 'invalidate token' do
      subject { get '/party/confirmation', confirmation_token: 'wwwwwww' }
      it { expect(subject).to redirect_to('/party/sign_in') }

      it { expect { subject }.not_to change { Party.last.confirmed? } }
    end
  end

end
