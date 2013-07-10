# == Schema Information
# Schema version: 20130701161224
#
# Table name: users
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  email           :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  password_digest :string(255)
#  remember_token  :string(255)
#  admin           :boolean          default(FALSE)
#
# Indexes
#
#  index_users_on_email           (email) UNIQUE
#  index_users_on_remember_token  (remember_token)
#

require 'spec_helper'

describe User do
  before do
    @user = User.new({
      name:                   "Joe Schmoe",
      email:                  "user@example.com",
      password:               "foobar",
      password_confirmation:  "foobar"
    })
  end
  subject { @user }


  it { should be_valid }

  describe "accessible attributes" do
    it { should respond_to(:name) }
    it { should respond_to(:email) }
    it { should respond_to(:password_digest) }
    it { should respond_to(:password) }
    it { should respond_to(:password_confirmation) }
    it { should respond_to(:authenticate) }
    it { should respond_to(:remember_token) }
    it { should respond_to(:admin) }
    it { should respond_to(:microposts) }
    it { should respond_to(:feed) }
    it { should_not be_admin }
    it "should not allow access to admin" do
      expect do
        User.new(admin: true)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end

  describe "name" do
    it "should not be valid when name is not present" do
      @user.name = " "
      should_not be_valid
    end
    it "should not be valid when name is too long" do
      @user.name = "a" * 81
      should_not be_valid
    end
  end

  describe "with admin attribute set to 'true'" do
    before do
      @user.save!
      @user.toggle!(:admin)
    end
    it { should be_admin }
  end

  describe "email" do
    it "should not be valid when email is not present" do
      @user.email = " "
      should_not be_valid
    end
    it "should not be valid when email format is invalid" do
      addresses = %w[
        user@foo,com
        user_at_foo.org
        example.user@foo.foo@bar_baz.com
        foo@bar+baz.com
      ]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        should_not be_valid
      end
    end
    it "should be valid when format is valid" do
      addresses = %w[
        user@foo.COM
        A_US-ER@f.b.org
        frst.lst@foo.jp
        a+b@baz.cn
        longaddressherethatislong@longbutvaliddomain.domain
      ]
      addresses.each do |valid_address|
        @user.email = valid_address
        should be_valid
      end
    end
    it "should not be valid when email is already taken, regardless of case" do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
      should_not be_valid
    end
    it "should be saved in all lower-case" do
      mixed_case_email = "USer@eXaMPlE.Com"
      @user.email = mixed_case_email
      @user.save
      @user.reload.email.should == mixed_case_email.downcase
    end
  end

  describe "password" do
    it "is not present it should not be valid" do
      @user.password = @user.password_confirmation = ' '
      should_not be_valid
    end
    it "confirmation is nil it should not be valid" do
      @user.password_confirmation = nil
      should_not be_valid
    end
    it "is too short it should not be valid" do
      @user.password = @user.password_confirmation = "a" * 5
      should_not be_valid
    end
  end

  describe "authentication method" do
    before { @user.save }
    let(:found_user) { User.find_by_email(@user.email) }

    describe "with valid password" do
      it { should == found_user.authenticate(@user.password) }
    end
    describe "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }
      it { should_not == user_for_invalid_password }
      specify { user_for_invalid_password.should be_false }
    end
  end

  it "remember token should not be blank" do
    @user.save
    @user.remember_token.should_not be_blank
  end

  describe "micropost association" do
    before { @user.save }
    let!(:older_micropost) do
      FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago )
    end
    let!(:newer_micropost) do
      FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago )
    end

    it "should have the right microposts in the right order" do
      # simultaneously tests that the has_many association is working,
      # and that the microposts are returned with newest on top
      @user.microposts.should == [newer_micropost, older_micropost]
    end
    it "should destory associated microposts on delete" do
      microposts = @user.microposts.dup
      @user.destroy
      # sanity check
      microposts.should_not be_empty
      microposts.each do |post|
        Micropost.find_by_id(post.id).should be_nil
      end
    end

    describe "feed" do
      describe "should have a list of microposts" do
        its(:feed) { should include(newer_micropost) }
        its(:feed) { should include(older_micropost) }
      end

      describe "not all microposts" do
        let(:unfollowed_post) do
          FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
        end
        its(:feed) { should_not include(unfollowed_post) }
      end
    end
  end

end
