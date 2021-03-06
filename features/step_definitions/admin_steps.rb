Given /^I am logged in as an administrator$/ do
  @admin = FactoryGirl.create(:confirmed_user, email: "admin@example.com")
  @admin.save
  @admin.add_role :admin
  sign_in(@admin)
end

When /^I visit the users page$/ do
  visit users_path(:locale => :fr)
end

When /^I click a link "([^"]*)"$/ do |arg1|
  click_on (arg1)
end

Then /^I should see a list of users$/ do
  page.should have_content @user[:email]
end

Then /^I should see an access denied message$/ do
  page.should have_content "Not authorized as an administrator"
end

Then /^show me the page$/ do
  save_and_open_page
end

Then /^I should see "(.*?)"$/ do |text|
  page.should have_content(text)
end
