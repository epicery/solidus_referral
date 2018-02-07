require 'spec_helper'

describe Spree::Order do
  let(:referrer) { create(:user) }
  let(:user) { create(:user, referrer: referrer) }

  let!(:store_credit_type) { create(:secondary_credit_type) }
  let!(:store_credit_category) { create(:store_credit_category, name: 'Default') }

  let(:referral_action) { Spree::Promotion::Actions::AddStoreCreditToReferrer.new }
  let(:free_shipping_action) { Spree::Promotion::Actions::FreeShipping.new }

  let(:user_is_referred_rule) { Spree::Promotion::Rules::UserIsReferred.new }
  let(:first_order_rule) { Spree::Promotion::Rules::FirstOrder.new }

  let(:free_shipping_promotion) { create(:promotion, apply_automatically: true, promotion_rules: [user_is_referred_rule, first_order_rule], promotion_actions: [free_shipping_action]) }
  let(:referral_promotion) { create(:promotion, apply_automatically: true, promotion_rules: [user_is_referred_rule, first_order_rule], promotion_actions: [referral_action]) }

  let(:first_cart) { create(:order_ready_to_complete, user: user) }
  let(:second_cart) { create(:order_ready_to_complete, user: user) }

  def add_variant(cart)
    cart.contents.add(create(:variant))
  end

  def complete_cart(cart)
    add_variant(cart)
    cart.next! until cart.state == 'confirm'
    cart.complete!
  end

  # In the following tests, we trigger PromotionHandler::Cart#activate by adding a variant to a Spree::Order in order to check our AddStoreCreditToReferrer action is bypassed, since we want to perform it later on order completion.

  # We then transition the order through `complete` to verify our custom action is performed.
  describe 'carts transitioning to `complete`' do
    describe '#trigger_perform_at_completion_in_promotion_actions' do
      after(:each) { complete_cart(first_cart) }

      context 'when the promotion has one action responding to #perform_at_completion' do
        before { referral_promotion }

        it 'should call #perform_at_completion once for that action' do
          action = referral_promotion.actions.first

          expect(action).not_to be_nil
          expect(action).to eql(referral_action)

          expect(action).to respond_to(:perform_at_completion)
          expect_any_instance_of(action.class).to receive(:perform_at_completion).once
        end
      end

      context 'when the promotion has no action responding to #perform_at_completion' do
        before { free_shipping_promotion }

        it 'should do nothing' do
          action = free_shipping_promotion.actions.first

          expect(action).not_to be_nil
          expect(action).to eql(free_shipping_action)

          expect(action).not_to respond_to(:perform_at_completion)
          expect_any_instance_of(action.class).not_to receive(:perform_at_completion)
        end
      end
    end

    describe 'referrer\'s store credits count' do
      before { referral_promotion }

      context 'for the very first time' do
        it 'should trigger the promotion action' do
          expect(referrer.store_credits.count).to eql(0)

          complete_cart(first_cart)

          expect(referrer.store_credits.count).to eql(1)
        end
      end

      context 'after having already ordered' do
        context 'when an old cart gets "recycled" for completion' do
          before { first_cart; complete_cart(second_cart) }

          # This example should NOT fail if we consider Solidus should take account of stores that wish to "recycle" uncompleted orders.

          # In this situation, Spree::Promotion::Rules::FirstOrder#completed_at should return a collection of orders ordered by `completed_at` to ensure we always compare the instantiated order with the the first truly completed order, not the first one provided by the Database.
          it 'should not trigger the promotion action' do
            pending('Issue with how Solidus handles "recycled" carts')
            expect(referrer.store_credits.count).to eql(1)

            complete_cart(first_cart)

            expect(referrer.store_credits.count).to eql(1)
          end
        end

        context 'when completing a new cart' do
          before { complete_cart(first_cart) }

          it 'should not trigger the promotion action' do
            expect(referrer.store_credits.count).to eql(1)

            complete_cart(second_cart)

            expect(referrer.store_credits.count).to eql(1)
          end
        end
      end
    end
  end

  describe 'carts in states before `complete`' do
    before { referral_promotion }

    context 'when user has already ordered and orders again' do
      before { complete_cart(first_cart) }

      it 'should not trigger the promotion action' do
        expect(referrer.store_credits.count).to eql(1)

        second_cart.contents.add(create(:variant))

        expect(referrer.store_credits.count).to eql(1)
      end
    end

    context 'when user has never ordered and orders for the first time' do
      it 'should trigger the promotion action' do
        expect(referrer.store_credits.count).to eql(0)

        first_cart.contents.add(create(:variant))

        expect(referrer.store_credits.count).to eql(0)
      end
    end
  end
end
