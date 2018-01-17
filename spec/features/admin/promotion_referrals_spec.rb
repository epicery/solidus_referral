require 'spec_helper'

describe "Promotion Adjustments", type: :feature, js: true do
  stub_authorization!

  context "enabling referrals", js: true do
    before(:each) do
      visit spree.admin_path
      click_link "Promotions"
      click_link "New Promotion"
      expect(page).to have_title("New Promotion - Promotions")
    end

    it "should allow an admin to combine first-order & user-is-referred rules with referrer-crediting action" do
      fill_in "Name", with: "Referrals"
      choose "Apply to all orders"
      click_button "Create"
      expect(page).to have_title("Referrals - Promotions")

      # Select rule that requires a user to be referred
      select "User is referred", from: "Add rule of type"
      within('#rule_fields') { click_button "Add" }

      within('#rule_fields') { click_button "Update" }

      expect(page).to have_content('User must be referred')

      # Select first order rule
      select "First order", from: "Add rule of type"
      within('#rule_fields') { click_button "Add" }

      within('#rule_fields') { click_button "Update" }

      expect(page).to have_content('Must be the customer\'s first order')

      # Select action that adds store credit to a user's referrer
      select "Add store credit to referrer", from: "Add action of type"
      within('#action_fields') { click_button "Add" }

      # Verify admin can change the default amount
      amount_field = find('input[id^="promotion_promotion_actions_attributes_"][id$="_preferred_amount"]')
      amount_field.set(5.0)

      within('#action_fields') { click_button "Update" }

      expect(page).to have_content('Add store credit to referrer')

      # Verify promotion is associated to the expected rule(s) and action(s)
      promotion = Spree::Promotion.find_by(name: "Referrals")
      expect(promotion.codes).to be_empty

      expect(promotion.rules).to include(
        Spree::Promotion::Rules::UserIsReferred,
        Spree::Promotion::Rules::FirstOrder
      )

      expect(promotion.actions.first).to be_a(Spree::Promotion::Actions::AddStoreCreditToReferrer)
      expect(promotion.actions.first.preferred_amount).to eql(5.0)
    end
  end
end
