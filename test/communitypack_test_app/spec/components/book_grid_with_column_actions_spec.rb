require 'spec_helper'

describe BookGridWithColumnActions, :type => :request, :js => true do
  before :each do
    FactoryGirl.create(:book, :title => "One Hundred Years of Solitude")
    FactoryGirl.create(:book, :title => "Moby Dick")
  end

  it "should delete a record via pressing the delete icon" do
    visit '/components/BookGridWithColumnActions'
    grid_count.should == 2
    click_action_icon("Delete row")
    click_button("Yes")
    grid_count.should == 1
  end
end


