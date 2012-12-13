require 'spec_helper'

describe ApplicationController do
  let (:user){FactoryGirl.create(:user)}

   controller do
      def after_sign_in_path_for(resource)
        super resource
      end

      def after_sign_up_path_for(resource)
        super resource
      end
   end

    describe "#after_sign_in_path_for" do
      it "redirects to user" do
        controller.after_sign_in_path_for(user).should == user_path(user)
      end
    end

    describe "#after_sign_up_path_for" do
      it "redirects to edit user" do
        controller.after_sign_up_path_for(user).should == edit_user_path(user)
      end
    end
end
