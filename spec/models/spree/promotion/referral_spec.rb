require 'spec_helper'

describe 'Add store credit to referrer on first order' do
  let(:user) { create(:user) }
  let!(:referrer) { create(:user, referred_users: [user]) }

  let!(:first_order) { create(:completed_order_with_totals, user: user) }
  let(:second_order) { create(:order, user: user)}

  let!(:store_credit_type) { create(:secondary_credit_type) }
  let!(:store_credit_category) { create(:store_credit_category, name: 'Default') }

  let(:credit_referrer_action) { Spree::Promotion::Actions::AddStoreCreditToReferrer.new }

  let(:user_is_referred_rule) { Spree::Promotion::Rules::UserIsReferred.new }
  let(:first_order_rule) { Spree::Promotion::Rules::FirstOrder.new }

  let!(:promotion) { create(:promotion, promotion_rules: [user_is_referred_rule, first_order_rule], promotion_actions: [credit_referrer_action]) }

  context 'when the user is referred and orders for the first time' do
    subject { promotion.eligible?(first_order) }

    it { is_expected.to be true }
  end

  context 'when the user is not referred and orders for the first time' do
    before { user.update_columns(referrer_id: nil) }

    subject { promotion.eligible?(first_order) }

    it { is_expected.to be false }
  end

  context 'when the user is referred and has completed at least one order' do
    subject { promotion.eligible?(second_order) }

    it { is_expected.to be false }
  end

  context 'when the user is not referred and has completed at least one order'  do
    before { user.update_columns(referrer_id: nil) }

    subject { promotion.eligible?(second_order) }

    it { is_expected.to be false }
  end
end