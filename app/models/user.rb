class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token

  # Callbacks:
  # Before saving user to db email is downcased.
  before_save :downcase_email
  # Before creating (only! not before updating!) email activation digest is created.
  before_create :create_activation_digest

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
  # -It provides validation: password should be present on CREATION. This means
  #  that password can be nil on user edit for example
  has_secure_password
  validates :password, presence: true, length: {minimum: 6, maximum: 255},
            # This alloq_nil dosen't apply to user creation. Thanks to this
            # user dosen't need to provide password during profile edit
            allow_nil: true


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
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
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

  private
    def downcase_email
      self.email.downcase!
    end

    def create_activation_digest
      # Create the token and digest.
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
