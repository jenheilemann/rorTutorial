# == Schema Information
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

class User < ActiveRecord::Base
  attr_accessible :email, :name, :password, :password_confirmation
  has_secure_password

  validates :name,                  presence: true, length: { maximum: 80 }
  validates :password,              presence: true, length: { minimum: 6 }
  validates :password_confirmation, presence: true

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  # ensure email uniqueness in all systems regardless of case
  before_save { email.downcase! }

  # remember_token matches with the session manager to handle logins
  before_save :create_remember_token

  # hide the error message about the password digest
  after_validation { self.errors.messages.delete(:password_digest) }

  self.per_page = 15

  private
    def create_remember_token
      self.remember_token = "#{Time.now.hash}#{SecureRandom.urlsafe_base64}"
    end
end
