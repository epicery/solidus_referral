require 'spec_helper'

describe 'Add store credit to referrer on first order' do
  let(:referrer) { create(:user) }
  let(:user) { create(:user, referrer: referrer) }

  let(:uncompleted_order) { create(:order, user: user) }

  let!(:store_credit_type) { create(:secondary_credit_type) }
  let!(:store_credit_category) { create(:store_credit_category, name: 'Default') }

  let(:credit_referrer_action) { Spree::Promotion::Actions::AddStoreCreditToReferrer.new }

  let(:user_is_referred_rule) { Spree::Promotion::Rules::UserIsReferred.new }
  let(:first_order_rule) { Spree::Promotion::Rules::FirstOrder.new }

  let!(:promotion) { create(:promotion, promotion_rules: [user_is_referred_rule, first_order_rule], promotion_actions: [credit_referrer_action]) }

  describe 'when a user orders' do
    context 'when the user has already ordered at least once' do
      let!(:completed_order) { create(:completed_order_with_totals, user: user) }

      context 'when the user is referred' do
        subject { promotion.eligible?(uncompleted_order) }

        it { is_expected.to be false }
      end

      context 'when the user is not referred'  do
        before { user.update_columns(referrer_id: nil) }

        subject { promotion.eligible?(uncompleted_order) }

        it { is_expected.to be false }
      end
    end

    context 'when the user has never completed an order' do
      context 'when the user is referred' do
        subject { promotion.eligible?(uncompleted_order) }

        it { is_expected.to be true }
      end

      context 'when the user is not referred' do
        before { user.update_columns(referrer_id: nil) }

        subject { promotion.eligible?(uncompleted_order) }

        it { is_expected.to be false }
      end
    end
  end

  describe 'Spree::Promotion#activate' do
    let(:payload) { { order: uncompleted_order } }

    # We don't want to perform the referrer-crediting action at the usual stage of the checkout flow. Instead, in the context of referrals, the appropriate thing is to only credit the user's referrer when the first order is actually completed.
    it 'should not credit the referrer on promotion activation' do
      expect(referrer.store_credits).to be_empty

      promotion.activate(payload)

      expect(referrer.store_credits).to be_empty
    end
  end
end
