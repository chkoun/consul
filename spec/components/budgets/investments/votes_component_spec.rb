require "rails_helper"

describe Budgets::Investments::VotesComponent do
  describe "vote link" do
    before do
      Setting["feature.allow_remove_investments_supports"] = false
    end

    context "when investment shows votes" do
      let(:investment) { create(:budget_investment, title: "Renovate sidewalks in Main Street") }
      let(:component) { Budgets::Investments::VotesComponent.new(investment) }

      before { allow(investment).to receive(:should_show_votes?).and_return(true) }

      it "displays a button to support the investment to identified users" do
        sign_in(create(:user))

        render_inline component

        expect(page).to have_button count: 1
        expect(page).to have_button "Support", title: "Support this project", disabled: false
        expect(page).to have_button "Support Renovate sidewalks in Main Street"
      end

      it "disables the button to support the investment to unidentified users" do
        render_inline component

        expect(page).to have_button count: 1, disabled: :all
        expect(page).to have_button "Support", disabled: true
      end

      it "does not shows the button to remove support when setting is disabled" do
        user = create(:user)
        user.up_votes(investment)
        sign_in(user)

        render_inline component

        expect(page).not_to have_button count: 1, disabled: :all
        expect(page).not_to have_button "Remove your support"
        expect(page).not_to have_button "Remove your support to Renovate sidewalks in Main Street"
      end

      it "shows the button to remove support when users when setting is enabled" do
        Setting["feature.allow_remove_investments_supports"] = true
        user = create(:user)
        user.up_votes(investment)
        sign_in(user)

        render_inline component

        expect(page).to have_button count: 1, disabled: :all
        expect(page).to have_button "Remove your support"
        expect(page).to have_button "Remove your support to Renovate sidewalks in Main Street"
      end
    end
  end
end
