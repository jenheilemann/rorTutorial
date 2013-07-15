# == Schema Information
# Schema version: 20130711142646
#
# Table name: relationships
#
#  id          :integer          not null, primary key
#  follower_id :integer
#  followed_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_relationships_on_followed_id                  (followed_id)
#  index_relationships_on_follower_id                  (follower_id)
#  index_relationships_on_follower_id_and_followed_id  (follower_id,followed_id) UNIQUE
#

require 'spec_helper'

describe Relationship do

  let(:follower) { FactoryGirl.create(:user) }
  let(:followed) { FactoryGirl.create(:user) }
  let(:relationship) { follower.relationships.build(followed_id: followed.id) }

  subject { relationship }

  it { should be_valid }

  describe "accessible attributes" do
    it { should respond_to(:follower) }
    it { should respond_to(:followed) }
    it "should not allow access to follower_id" do
      expect do
        Relationship.new(follower_id: follower.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    it "should not allow a duplicate follower" do
      expect do
        follower.relationships.create(followed_id: followed.id)
        follower.relationships.create(followed_id: followed.id)
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end
    describe "when followed id is not present" do
      before { relationship.followed_id = nil }
      it { should_not be_valid }
    end
    describe "when follower id is not present" do
      before { relationship.follower_id = nil }
      it { should_not be_valid }
    end
  end

  describe "follower methods" do
    let(:bad_relationship) { follower.relationships.build(followed_id: follower.id) }

    its(:follower) { should == follower }
    its(:followed) { should == followed }
    it "should not allow a user follow themselves" do
      bad_relationship.should_not be_valid
    end
  end
end
