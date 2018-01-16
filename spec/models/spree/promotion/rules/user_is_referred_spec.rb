require 'spec_helper'

describe Spree::Promotion::Rules::UserIsReferred, type: :model do
  let(:rule) { Spree::Promotion::Rules::UserIsReferred.new }

  describe 'applicability' do
    subject { described_class.new.applicable?(promotable) }

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
    let(:user) { create(:user) }
    let(:order) { create(:order, user: user) }

    subject { rule.eligible?(order) }

    context 'when the user has been referred by someone' do
      let!(:referrer) { create(:user, referred_users: [user]) }

      it { is_expected.to be true }
    end

    context 'when the user has not been referred by anyone' do
      it { is_expected.to be false }

      it "sets an error message" do
        rule.eligible?(order)
        expect(rule.eligibility_errors.full_messages.first).
          to eq "The user is not referred by anyone."
      end
    end
  end
end