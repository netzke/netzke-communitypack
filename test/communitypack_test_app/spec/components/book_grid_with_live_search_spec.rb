require 'spec_helper'

describe BookGridWithLiveSearch, :type => :request, :js => true do
  before :each do
    FactoryGirl.create(:book, :title => "One Hundred Years of Solitude")
    FactoryGirl.create(:book, :title => "Moby Dick")
  end

  it "search for 'Moby' should list 1 book" do
    visit '/components/BookGridWithLiveSearch'
    grid_count.should == 2
    fill_in 'live_search_field', :with => 'Moby'
    sleep(0.5) # wait until search gets triggered
    grid_count.should == 1
  end

  it "search for 'Moby' should list 'Moby Dick'" do
    visit '/components/BookGridWithLiveSearch'
    grid_count.should == 2
    fill_in 'live_search_field', :with => 'Moby'
    sleep(0.5) # wait until search gets triggered
    grid_cell_value(0,:title).should == "Moby Dick"
  end


  it "search for 'not a book title' shouldn't list anything" do
    visit '/components/BookGridWithLiveSearch'
    fill_in 'live_search_field', :with => 'not a book title'
    sleep(0.5) # wait until search gets triggered
    grid_count.should == 0
  end
end

