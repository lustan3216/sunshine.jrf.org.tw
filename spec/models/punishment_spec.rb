# == Schema Information
#
# Table name: punishments
#
#  id               :integer          not null, primary key
#  profile_id       :integer
#  decision_unit    :string
#  unit             :string
#  title            :string
#  claimant         :string
#  punish_no        :string
#  decision_no      :string
#  punish_type      :string
#  relevant_date    :date
#  decision_result  :text
#  decision_source  :text
#  reason           :text
#  is_anonymous     :boolean
#  anonymous_source :text
#  anonymous        :string
#  origin_desc      :text
#  proposer         :string
#  plaintiff        :string
#  defendant        :string
#  reply            :text
#  reply_source     :text
#  punish           :text
#  content          :text
#  summary          :text
#  memo             :text
#  created_at       :datetime
#  updated_at       :datetime
#  is_hidden        :boolean
#  status           :text
#  owner_id         :integer
#  owner_type       :string
#

require 'rails_helper'

RSpec.describe Punishment, type: :model do
  let!(:punishment) { create :punishment }

  it 'FactoryGirl' do
    expect(punishment).not_to be_new_record
  end

  it 'has_many :punishment, dependent: :destroy' do
    expect(Punishment.count).to eq(1)
    owner = punishment.owner
    owner.destroy
    expect(Punishment.count).to be_zero
  end

  it '#punishments_count counter cache' do
    judge = create :judge
    Punishment.create decision_unit: 'foofoo', owner: judge
    judge.reload
    expect(judge.punishments_count).to eq(1)
    Punishment.last.destroy
    judge.reload
    expect(judge.punishments_count).to be_zero
  end
end
