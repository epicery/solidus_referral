require 'spec_helper'

describe Spree::User do
  let(:sponsor) { create(:user) }

  let(:sponsored_user1) { create(:user) }
  let(:sponsored_user2) { create(:user) }

  before do
    sponsor.sponsored_users << sponsored_user1
    sponsor.sponsored_users << sponsored_user2
  end

  describe 'self-referential relationship' do
    it 'a \'sponsor\' can sponsor one or many users' do
      sponsored_users = sponsor.sponsored_users

      expect(sponsored_users.count).to eql(2)
      expect(sponsored_users).to include(sponsored_user1, sponsored_user2)
    end

    it 'a sponsored user belongs to just one sponsor' do
      [sponsored_user1, sponsored_user2].each do |su|
        expect(su.sponsor).to eql(sponsor)
      end
    end
  end
end