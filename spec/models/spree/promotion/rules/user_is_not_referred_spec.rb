require 'spec_helper'

describe Spree::Promotion::Rules::UserIsNotReferred, type: :model do
  let(:rule) { described_class.new }

  describe 'applicability' do
    subject { rule.applicable?(promotable) }

    context "when the promotable is an order" do
      let(:promotable) { Spree::Order.new }

      it { is_expected.to be true }
    end

    context "when the promotable is not a order" do
      let(:promotable) { Spree::LineItem.new }

      it { is_expected.to be false }
    end
  end

  describe 'eligibility' do
    let(:order) { create(:order, user: user) }

    subject { rule.eligible?(order) }

    context 'anonymous cart' do
      let(:user) { nil }

      it { is_expected.to be false }

      it "sets an error message" do
        rule.eligible?(order)
        expect(rule.eligibility_errors.full_messages.first).
          to eq "You need to login before applying this coupon code."
      end
    end

    context 'cart with user' do
      let(:user) { create(:user) }

      context 'when the user has been referred by someone' do
        let!(:referrer) { create(:user, referred_users: [user]) }

        it { is_expected.to be false }

        it "sets an error message" do
          rule.eligible?(order)
          expect(rule.eligibility_errors.full_messages.first).
            to eq "User is referred. Promotion cannot be applied."
        end
      end

      context 'when the user has not been referred by anyone' do
        it { is_expected.to be true }
      end
    end
  end
end
