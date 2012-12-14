require 'spec_helper'

describe UsersHelper do
  let (:message) {FactoryGirl.create(:message)}
  
  describe '#new_message_visibility(message)' do
    it 'should return hidden if message has no errors' do
      helper.new_message_visibility(message).should eql("hidden")
    end
    it 'should return shown if message has errors' do
      errors = {:subject=>["can't be blank"]}  
      errors.each { |attr, msg| message.errors.add(attr, msg) }
      helper.new_message_visibility(message).should eql("shown")
    end
  end

  describe '#date_for_inbox(message)' do
    it 'should return message created at as mm/dd/yy hh:mm am/pm' do
      message.created_at = "January 15, 1974 at 12:00pm"
      helper.date_for_inbox(message).should eql("01/15/74 12:00PM")
    end
  end

  describe '#subject_link_weight(message)' do
    it 'should return empty string if message read' do
      message.read = true
      helper.subject_link_weight(message).should eql("")
    end
    it 'should return bolder_link if message not read' do
      helper.subject_link_weight(message).should eql("bolder_link")
    end
  end
end
