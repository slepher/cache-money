require 'spec_helper'

describe Cash do
  describe 'when disabled' do
    before(:each) do
      Cash.enabled = false
      
      mock($memcache).get.never
      mock($memcache).add.never
      mock($memcache).set.never
    end
      
    after(:each) do
      Cash.enabled = true
    end
  
    it 'creates and looks up objects without using cache' do
      story = Story.create!
      Story.find(story.id).should == story
    end
    
    it 'updates objects without using cache' do
      story = Story.create!
      story.title = 'test'
      story.save!
    end
    
    it 'should find using indexed condition without using cache' do
      Story.find(:all, :conditions => {:title => 'x'})
    end
  end
end