require 'spec_helper'

describe Spree::User do
  let!(:referrer) { create(:user) }

  let(:referred_user1) { create(:user) }
  let(:referred_user2) { create(:user) }

  before do
    referrer.referred_users << referred_user1
    referrer.referred_users << referred_user2
  end

  describe 'self-referential relationship' do
    it 'a referrer can sponsor one or several users' do
      referred_users = referrer.referred_users

      expect(referred_users.count).to eql(2)
      expect(referred_users).to include(referred_user1, referred_user2)
    end

    it 'a referred user belongs to just one referrer' do
      [referred_user1, referred_user2].each do |su|
        expect(su.referrer).to eql(referrer)
      end
    end
  end

  describe 'callbacks' do
    subject { Spree::User.new }

    it 'generate a referral code before each user creation' do
      expect(subject).to receive(:ensure_user_has_referral_code)
      subject.run_callbacks :create
    end

    it 'each newly created user should have a referral code of the expected format' do
      expect(subject.referral_code).to be_nil

      subject.run_callbacks :create

      expect(subject.referral_code).to match(/\bREF\d{6}\b/)
    end
  end
end