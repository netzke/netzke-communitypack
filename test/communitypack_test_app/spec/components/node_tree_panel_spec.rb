require 'spec_helper'

describe NodeTreePanel, :type => :request, :js => true do
  before :each do
    @r1 = FactoryGirl.create(:node, :title => "Root 1")
    FactoryGirl.create(:node, :title => "Root 2")

    FactoryGirl.create(:node, :title => "Root 1 > Child 1", :parent => @r1)
    FactoryGirl.create(:node, :title => "Root 1 > Child 2", :parent => @r1)
    @c3 = FactoryGirl.create(:node, :title => "Root 1 > Child 3", :parent => @r1)

    FactoryGirl.create(:node, :title => "Root 1 > Child 3 > Child 1", :parent => @c3)
    FactoryGirl.create(:node, :title => "Root 1 > Child 3 > Child 2", :parent => @c3)
  end

  it "should list all root nodes" do
    visit '/components/NodeTreePanel'
    grid_count.should == 2
  end

  it "should load children of a node" do
    visit '/components/NodeTreePanel'
    expand_node(@r1.id)
    children_count(@r1.id).should == 3

    expand_node(@c3.id)
    children_count(@c3.id).should == 2
  end
end
