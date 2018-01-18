require 'spec_helper'

describe Spree::Order do
  let(:referrer) { create(:user) }
  let(:user) { create(:user, referrer: referrer) }

  let!(:store_credit_type) { create(:secondary_credit_type) }
  let!(:store_credit_category) { create(:store_credit_category, name: 'Default') }

  let(:credit_referrer_action) { Spree::Promotion::Actions::AddStoreCreditToReferrer.new }

  let(:user_is_referred_rule) { Spree::Promotion::Rules::UserIsReferred.new }
  let(:first_order_rule) { Spree::Promotion::Rules::FirstOrder.new }

  let!(:promotion) { create(:promotion, apply_automatically: true, promotion_rules: [user_is_referred_rule, first_order_rule], promotion_actions: [credit_referrer_action]) }

  let(:order_ready_to_complete) { create(:order_ready_to_complete, user: user) }

  # In the following tests, we want to trigger PromotionHandler::Cart#activate to check our action is bypassed since we want to perform it on order completion.

  # Adding an item to an existing order will trigger the handler.

  # We then transition the order through `complete` (or not) to verify our custom action is performed (or not).
  describe 'orders going through transition to `complete`' do
    context 'when user has already ordered and does so again' do
      let(:completed_order) do
        create(:order_ready_to_complete, user: user).tap do |o|
          o.contents.add(create(:variant))
          o.next! until o.state == 'confirm'
          o.complete!
        end
      end

      context 'when the an older uncompleted order gets "recycled" for completion' do
        before { order_ready_to_complete; completed_order }

        # This example should NOT fail if we consider Solidus should anticipate stores that wish to "recycle" uncompleted orders.

        # In this situation, Spree::Promotion::Rules::FirstOrder#completed_at should return a collection of orders ordered by `completed_at` to ensure we always compare the instantiated order with the the first truly completed order, not the first one provided by the Database.
        it 'should not trigger the promotion action' # do
 #          expect(referrer.store_credits.count).to eql(1)
 #
 #          order_ready_to_complete.contents.add(create(:variant))
 #          order_ready_to_complete.next! until order_ready_to_complete.state == 'confirm'
 #          order_ready_to_complete.complete!
 #
 #          expect(referrer.store_credits.count).to eql(1)
 #        end
      end

      context 'when the newly completed order was created after the first completed one' do
        before { completed_order }

        it 'should not trigger the promotion action' do
          expect(referrer.store_credits.count).to eql(1)

          order_ready_to_complete.contents.add(create(:variant))
          order_ready_to_complete.next! until order_ready_to_complete.state == 'confirm'
          order_ready_to_complete.complete!

          expect(referrer.store_credits.count).to eql(1)
        end
      end
    end

    context 'when user has never ordered and does so for the first time' do
      it 'should trigger the promotion action' do
        expect(referrer.store_credits.count).to eql(0)

        order_ready_to_complete.contents.add(create(:variant))
        order_ready_to_complete.next! until order_ready_to_complete.state == 'confirm'
        order_ready_to_complete.complete!

        expect(referrer.store_credits.count).to eql(1)
      end
    end
  end

  describe 'orders in states before reaching `complete`' do
    context 'when user has already ordered and orders again' do
      let!(:completed_order) do
        create(:order_ready_to_complete, user: user).tap do |o|
          o.contents.add(create(:variant))
          o.next! until o.state == 'confirm'
          o.complete!
        end
      end

      it 'should not trigger the promotion action' do
        expect(referrer.store_credits.count).to eql(1)

        order_ready_to_complete.contents.add(create(:variant))

        expect(referrer.store_credits.count).to eql(1)
      end
    end

    context 'when user has never ordered and orders for the first time' do
      it 'should trigger the promotion action' do
        expect(referrer.store_credits.count).to eql(0)

        order_ready_to_complete.contents.add(create(:variant))

        expect(referrer.store_credits.count).to eql(0)
      end
    end
  end
end
