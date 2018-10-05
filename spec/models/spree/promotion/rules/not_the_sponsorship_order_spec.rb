require 'spec_helper'

describe Spree::Promotion::Rules::NotTheSponsorshipOrder, type: :model do
  let(:cart) { build(:order, user: user) }

  let(:rule) { described_class.new }

  subject { rule.eligible?(cart) }

  describe '#eligible?' do
    context 'anonymous cart' do
      let(:user) { nil }

      it { should be true }
    end

    context 'cart with user' do
      let(:user) { create(:user) }

      context 'when the user has already ordered' do
        let!(:order) do
          create(:order_ready_to_complete, user: user).tap do |order|
            order.next! until order.state == 'confirm'
            order.complete!
          end
        end

        context 'and the user is referred' do
          let!(:referrer) { create(:user, referred_users: [user]) }
          it { should be true }
        end

        context 'and the user is not referred' do
          it { should be true }
        end
      end

      context 'when the user has never ordered' do
        context 'and the user is referred' do
          let!(:referrer) { create(:user, referred_users: [user]) }

          it { should be false }

          it "sets an error message" do
            rule.eligible?(cart)
            expect(rule.eligibility_errors.full_messages.first).
              to eq "The order is the order eligible to the sponsorship promotion and cannot be combined with any other promotion. Promotion cannot be applied."
          end
        end

        context 'and the user is not referred' do
          it { should be true }
        end
      end
    end
  end
end
