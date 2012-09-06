require 'spec_helper'

describe AuthorTreePanel, :wip => true, :type => :request, :js => true do
  before :each do
    @marquez = FactoryGirl.create(:author, :first_name => "Gabriel Garcia", :last_name => "Marquez", :id => 1)
    @dickens = FactoryGirl.create(:author, :first_name => "Charles", :last_name => "Dickens", :id => 2)
    @christie = FactoryGirl.create(:author, :first_name => "Agatha", :last_name => "Christie", :id => 3)
    FactoryGirl.create(:book, :title => "One Hundred Years of Solitude", :author => @marquez)
    FactoryGirl.create(:book, :title => "Love in the Time of Cholera", :author => @marquez)
    FactoryGirl.create(:book, :title => "Oliver Twist", :author => @dickens)
    FactoryGirl.create(:book, :title => "David Copperfield", :author => @dickens)
  end

  it "should list all authors" do
    visit '/components/AuthorTreePanel'
    grid_count.should == 3
  end

  it "should load children of a node" do
    visit '/components/AuthorTreePanel'
    expand_node("Author-1")
    children_count("Author-1").should == 2
  end
end

