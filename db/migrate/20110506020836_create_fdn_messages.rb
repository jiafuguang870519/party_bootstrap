class CreateFdnMessages < ActiveRecord::Migration

  def change
    create_table :fdn_messages do |t|
      t.string :subject
      t.text :body

      t.string :sender_type
      t.integer :sender_id

      t.integer :reply_of
      t.integer :forward_from
      t.integer :group_id

      t.integer :trashed_by_sender, :default => 0
      t.string :status
      t.text :receivers
      t.string :msg_type
      t.integer :msg_type_id

      t.timestamps
    end

    add_index :fdn_messages, [:sender_id, :sender_type, :trashed_by_sender, :status, :created_at], :name => 'fdn_messages_ind1'
  end

end
