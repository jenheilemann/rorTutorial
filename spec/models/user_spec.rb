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

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:admin) }

  it { should be_valid }
  it { should_not be_admin }

  describe "when name is not present" do
    before { @user.name = " " }
    it { should_not be_valid }
  end
  describe "when name is too long" do
    before { @user.name = "a" * 81 }
    it { should_not be_valid }
  end

  describe "with admin attribute set to 'true'" do
    before do
      # @user.save!
      @user.toggle!(:admin)
    end

    it { should be_admin }
  end

  describe "when email is not present" do
    before { @user.email = " " }
    it { should_not be_valid }
  end
  describe "when email format is invalid" do
    it "should be invalid" do
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
  end
  describe "when email format is valid" do
    it "should be valid" do
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
  end
  describe "when email is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.save
    end

    it { should_not be_valid }
  end
  describe "when email is already taken, regardless of case" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end

    it { should_not be_valid }
  end
  describe "when email address with a mixed case" do
    let(:mixed_case_email) { "USer@eXaMPlE.Com" }

    it "should be saved all lower-case" do
      @user.email = mixed_case_email
      @user.save
      @user.reload.email.should == mixed_case_email.downcase
    end
  end

  describe "when password is not present" do
    before { @user.password = @user.password_confirmation = ' ' }
    it { should_not be_valid }
  end
  describe "when password confirmation is nil" do
    before { @user.password_confirmation = nil }
    it { should_not be_valid }
  end

  describe "when a password is too short" do
    before { @user.password = @user.password_confirmation = "a" * 5 }
    it { should_not be_valid }
  end
  describe "return value of authentication method" do
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

  describe "remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
  end
end
