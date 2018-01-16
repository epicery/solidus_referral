require 'spec_helper'

describe Spree::Promotion::Actions::AddStoreCreditToReferrer, type: :model do
  let(:user) { create(:user) }
  let(:referrer) { create(:user, referred_users: [user]) }

  let(:store_credits) { referrer.store_credits }

  let!(:store_credit_type) { create(:secondary_credit_type) }
  let!(:store_credit_category) { create(:store_credit_category, name: 'Default') }

  let(:order) { create(:order, user: user) }

  let(:payload) { { order: order } }
  let(:action) { Spree::Promotion::Actions::AddStoreCreditToReferrer.new }

  describe '#perform' do
    it 'creates a store credit for the order\'s user\'s referrer' do
      amount = action.preferred_amount

      expect(store_credits).to be_empty

      action.perform(payload)

      expect(store_credits.reload.count).to eql(1)
      expect(store_credits.first.amount).to eql(amount)
    end
  end
end