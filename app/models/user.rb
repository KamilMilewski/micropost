class User < ApplicationRecord
  attr_accessor :remember_token
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


  # Remembers the user in database for use in persistent sessions.
  def remember
    self.remember_token = User.new_token
    # Using update_attribute here is important because it bypasses validation.
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Forgets the user (cancels effects of the remember method above).
  def forget
    update_attribute(:remember_token, nil)
  end

  # Return true if the given token matches the digest.
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # class methods:
  class << self

    # User class method. Creates digest of a given string.
    def digest(string)
      #cost defines computational cost of decrypting digested password.
      #Thin line arranges for low cost in test and development and high in prod.
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                    BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end

    # User class method. Return a random token. Token will be stored in cookie
    def new_token
      SecureRandom.urlsafe_base64
    end
  end
end
