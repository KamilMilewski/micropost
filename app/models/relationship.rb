class Relationship < ApplicationRecord
  belongs_to :follower, class_name: 'User'
  belongs_to :followed, class_name: 'User'
  # Since Rails 5 these validations are not required here.
  validates :follower_id, presence: true
  validates :followed_id, presence: true
end
