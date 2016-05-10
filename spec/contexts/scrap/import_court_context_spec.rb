require 'rails_helper'

RSpec.describe Scrap::ImportCourtContext, :type => :model do
  describe ".perform" do
    subject{ described_class.perform }
    it { expect{ subject }.to change{ Court.count } }
  end

  describe "#perform" do
    context "success" do
      let(:data_hash) { { fullname: "xxx", code: "TTT" } }
      subject{ described_class.new(data_hash).perform }

      it { expect{ subject }.to change { Court.count }.by(1) }
      it { expect(subject.full_name).to eq(data_hash[:fullname]) }
      it { expect(subject.code).to eq(data_hash[:code]) }
      it { expect(subject.court_type).to eq("法院") }
    end

    context "update old data" do
      let!(:court) { FactoryGirl.create(:court, full_name: "xxx", code: "ABC") }
      let(:data_hash) { { fullname: court.full_name, code: "TTT" } }
      subject{ described_class.new(data_hash).perform }

      it { expect{ subject }.not_to change { Court.count } }
      it { expect(subject.full_name).to eq(data_hash[:fullname]) }
      it { expect(subject.code).to eq(data_hash[:code]) }
    end

    context "data fullname incorrect" do
      let!(:court) { FactoryGirl.create(:court) }
      let(:data_hash) { { fullname: nil, code: "TTT" } }
      subject{ described_class.new(data_hash).perform }

      it { expect{ subject }.not_to change { Court.count } }
      it { expect(subject).to be_falsey }
    end

    context "data code incorrect" do
      let!(:court) { FactoryGirl.create(:court) }
      let(:data_hash) { { fullname: court.full_name, code: nil } }
      subject{ described_class.new(data_hash).perform }

      it { expect{ subject }.not_to change { Court.count } }
      it { expect(subject).to be_falsey }
    end

    context "assign default value" do
      context "is_hidden nil" do
        let(:data_hash) { { fullname: "xxx", code: "TTT" } }
        subject{ described_class.new(data_hash).perform }

        it { expect(subject.is_hidden).to be_truthy }
      end

      context "is_hidden not nil" do
        let(:data_hash) { { fullname: "xxx", code: "TTT" } }
        before { described_class.new(data_hash).perform }
        before { subject.update_attributes(is_hidden: false) }
        subject { described_class.new(data_hash).perform }

        it { expect{ subject }.not_to change { subject.is_hidden } }
        it { expect(subject.is_hidden).to be_falsey }
      end
    end
  end
end
