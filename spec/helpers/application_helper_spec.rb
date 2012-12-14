require 'spec_helper'

describe ApplicationHelper do
  let (:user) {FactoryGirl.create(:user, email:"app@rmry.com")}
  let (:other_user) {FactoryGirl.create(:user, email:"aprop@rmry.com")}
  let (:critique) {FactoryGirl.create(:critique)}
  describe '#viewer_is_user?(user)' do
    it 'returns true if viewer is current user' do
      sign_in(user)
      helper.viewer_is_user?(user).should be_true
    end
    it 'returns false if viewer is not current user' do
      sign_in(user)
      helper.viewer_is_user?(other_user).should be_false
    end
  end
  describe '#date_for_list(element)' do
    it 'returns the element date as MM/DD/YY' do
      critique.created_at = "January 15, 1974 at 12:00pm"
      helper.date_for_list(critique).should eql("01/15/74")
    end
  end
  describe '#rating_for(critique)' do
    it 'should return unrated if critique rating is nil' do
      helper.rating_for(critique).should eql("unrated")
    end
    it 'should return critique rating if present' do
      critique.rating = 10
      helper.rating_for(critique).should eql(10) 
    end
  end
end
