class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token

  has_many :microposts, dependent: :destroy
  # When user follows another user then this is a active relationship for him.
  # If he is being followed then it will be passive relationship.
  has_many :active_relationships, class_name:  'Relationship',
                                  foreign_key: 'follower_id',
                                  dependent:   :destroy
  has_many :following, through: :active_relationships, source: :followed
  # We could write here instead:
  # has_many :followeds, through: :active_relationships
  # But followeds sounds awkward so we are using :following instead and tell
  # Rails that source for them should be :followed ids.

  has_many :passive_relationships, class_name:  'Relationship',
                                   foreign_key: 'followed_id',
                                   dependent:   :destroy
  # Using source: :follower could be ommited here because Rails would infer
  # from :followers that he has to search for follower_id in table.
  has_many :followers, through: :passive_relationships, source: :follower

  # Callbacks:
  # Before saving user to db email is downcased.
  before_save :downcase_email
  # Before creating (only! not before updating!) email activation digest is created.
  before_create :create_activation_digest

  validates :name, presence: true, length: { maximum: 50 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  # This function requires bcrypt gem installed and password_digest column to be
  # present.It adds following funcionality:
  # -Save securely hashed password digest to the database.
  # -It adds up a pair of virtual attributes: password and password_confirmation.
  # -It adds validation if those two are present and match.
  # -It provides authenticate method that returns user if password is correct and
  #  false otherwise.
  # -It provides validation: password should be present on CREATION. This means
  #  that password can be nil on user edit for example
  has_secure_password
  validates :password, presence: true, length: { minimum: 6, maximum: 255 },
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

  # Activates an Account.
  def activate
    # update_columns hits the db only once comparing to using update_attribute
    # twice in thic case
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token),
                   reset_sent_at: Time.zone.now)
  end

  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Return true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  # Defindes a proto-feed.
  # See "Following users" for the full implementation.
  # Thanks to using ? here 'id' is escaped so we avoid SQL injection security
  # hole.
  def feed
    following_ids = 'SELECT followed_id FROM relationships
                     WHERE follower_id = :user_id'
    Micropost.where("user_id IN (#{following_ids}) OR user_id = :user_id",
                    user_id: id)
  end

  # class methods:
  class << self
    # User class method. Creates digest of a given string.
    def digest(string)
      # cost defines computational cost of decrypting digested password.
      # Thin line arranges for low cost in test and development and high in prod.
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                    BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end

    # User class method. Return a random token. Token will be stored in cookie
    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  # Follows a user.
  def follow(other_user)
    active_relationships.create(followed_id: other_user.id)
  end

  # Unfollow a user.
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  # Returns true if the current user is following the other user.
  def following?(other_user)
    following.include?(other_user)
  end

  private

  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    # Create the token and digest.
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
