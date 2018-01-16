require 'spec_helper'

describe Spree::Promotion::Rules::UserIsReferred, type: :model do
  let(:rule) { Spree::Promotion::Rules::UserIsReferred.new }
  let(:user) { mock_model(Spree::User) }

  describe 'applicability' do
    subject { described_class.new.applicable?(promotable) }

    context "when the promotable is an user" do
      let(:promotable) { Spree::User.new }

      it { is_expected.to be true }
    end

    context "when the promotable is not a order" do
      let(:promotable) { Spree::LineItem.new }

      it { is_expected.to be false }
    end
  end

  describe 'eligibility' do
    let(:user) { create(:user) }
    let(:promotion) { described_class.new }

    subject { promotion.eligible?(user) }

    context 'when the user has been referred by someone' do
      let!(:referrer) { create(:user, referred_users: [user]) }

      it { is_expected.to be true }
    end

    context 'when the user has not been referred by anyone' do
      it { is_expected.to be false }

      it "sets an error message" do
        promotion.eligible?(user)
        expect(promotion.eligibility_errors.full_messages.first).
          to eq "The user is not referred by anyone."
      end
    end
  end
end