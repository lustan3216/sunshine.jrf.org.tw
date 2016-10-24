require 'rails_helper'

RSpec.describe Parties::PhonesController, type: :request do
  before { signin_party }

  describe '#new' do
    subject! { get '/party/phone/new' }
    it { expect(response).to be_success }
  end

  describe '#create' do
    context 'success' do
      subject! { post '/party/phone', party: { unconfirmed_phone: '0911111111' } }
      it { expect(response).to redirect_to('/party/phone/verify') }
    end

    context 'failed' do
      subject! { post '/party/phone', party: { unconfirmed_phone: '0101' } }
      it { expect(response).to be_success }
      it { expect(response.body).to match('0101') }
    end
  end

  describe '#edit' do
    subject! { get '/party/phone/edit' }
    it { expect(response).to be_success }
  end

  describe '#update' do
    context 'success' do
      subject! { put '/party/phone', party: { unconfirmed_phone: '0911111111' } }
      it { expect(response).to redirect_to('/party/phone/verify') }
    end

    context 'failed' do
      subject! { put '/party/phone', party: { unconfirmed_phone: '0101' } }
      it { expect(response).to be_success }
      it { expect(response.body).to match('0101') }
    end
  end

  describe '#verify' do
    before { current_party.phone_varify_code = '1111' }

    context 'success' do
      subject! { get '/party/phone/verify' }
      it { expect(response).to be_success }
    end
  end

  describe '#verifing' do
    before { current_party.phone_varify_code = '1111' }

    context 'success' do
      subject! { put '/party/phone/verifing', party: { phone_varify_code: '1111' } }
      it { expect(response).to redirect_to('/party') }
    end

    context 'fail' do
      subject! { put '/party/phone/verifing', party: { phone_varify_code: '1234' } }
      it { expect(response).to be_success }
      it { expect(response.body).to match('1234') }
    end
  end

  describe '#resend' do
    before { current_party.unconfirmed_phone.value = '0911111111' }
    before { current_party.phone_varify_code = '1111' }

    context 'success' do
      subject! { put '/party/phone/resend' }
      it { expect(response).to redirect_to('/party/phone/verify') }
    end
  end

  describe '#can_verify?' do
    context 'success' do
      before { current_party.phone_varify_code = '1111' }
      subject! { get '/party/phone/verify' }

      it { expect(response).to be_success }
    end

    context 'should set phone_number' do
      subject! { get '/party/phone/verify' }

      it { expect(response).to redirect_to('/party/phone/edit') }
    end

  end
end
