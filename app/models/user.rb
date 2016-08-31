class User < ApplicationRecord
  before_save { email.downcase! }
  validates :name, presence: true, length: {maximum: 50}

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  validates :email, presence: true, length: {maximum: 255},
                    format: { with: VALID_EMAIL_REGEX},
                    uniqueness: {case_sensitive: false}

  #This function requires bcrypt gem installed and password_digest column to be
  #present.It adds following funcionality:
  # -Save securely hashed password digest to the database.
  # -It adds up a pair of virtual attributes: password and password_confirmation.
  # -It adds validation if those two are present and match.
  # -It provides authenticate method that returns user if password is correct and
  #  false otherwise.
  has_secure_password

  validates :password, presence: true, length: {minimum: 6, maximum: 255}
end
