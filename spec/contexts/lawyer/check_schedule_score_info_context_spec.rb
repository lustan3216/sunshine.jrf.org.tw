require "rails_helper"

describe Lawyer::CheckScheduleScoreInfoContext do
  let!(:lawyer) { FactoryGirl.create :lawyer }
  let!(:court) { FactoryGirl.create :court }
  let!(:story) { FactoryGirl.create :story, court: court}
  let!(:schedule) { FactoryGirl.create :schedule, story: story }
  let!(:params) { { court_id: court.id, year: story.year, word_type: story.word_type, number: story.number } }

  describe "#perform" do
    subject { described_class.new(lawyer).perform(params) }

    context "success" do
      it { expect(subject).to be_truthy }
    end

    context "court id invalid" do
      before { params[:court_id] = court.id + 1 }
      it { expect(subject).to be_falsey }
    end

    context "year empty" do
      before { params[:year] = "" }
      it { expect(subject).to be_falsey }
    end

    context "word_type empty" do
      before { params[:word_type] = "" }
      it { expect(subject).to be_falsey }
    end

    context "number empty" do
      before { params[:number] = "" }
      it { expect(subject).to be_falsey }
    end

    context "wrong info not found story" do
      before { params[:word_type] = "xxx" }
      it { expect(subject).to be_falsey }
    end

    context "story has pronounce_date?" do
      context "today pronounced " do
        before { story.update_attributes(pronounce_date: Time.zone.today) }
        it { expect(subject).to be_truthy }
      end

      context "yesterday pronounced " do
        before { story.update_attributes(pronounce_date: Time.zone.today - 1.days) }
        it { expect(subject).to be_falsey }
      end

      context "will pronounced " do
        before { story.update_attributes(pronounce_date: Time.zone.today + 1.days) }
        it { expect(subject).to be_truthy }
      end
    end

    context "story already_adjudge" do
      before { story.update_attributes(is_adjudge: true) }
      it { expect(subject).to be_falsey }
    end
  end
end
