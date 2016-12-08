class CreateRelationships < ActiveRecord::Migration[5.0]
  def change
    create_table :relationships do |t|
      t.integer :follower_id
      t.integer :followed_id

      t.timestamps
    end
    add_index :relationships, :follower_id
    add_index :relationships, :followed_id
    # Enforces uniqueness on follower_id - follower_id pairs. Thanks to this
    # user won't be able to follow given user twice - which dosen't make sense.
    add_index :relationships, [:follower_id, :followed_id], unique: true
  end
end
