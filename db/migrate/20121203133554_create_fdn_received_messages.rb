class CreateFdnReceivedMessages < ActiveRecord::Migration
  def change
    create_table :fdn_received_messages do |t|
      t.integer :message_id
      t.integer :receiver_id
      t.string :receiver_type
      t.integer :trashed_by_receiver, :default => 0
      t.integer :read, :default => 0
      t.datetime :read_at
      t.integer :created_at
      t.integer :updated_at

      t.timestamps
    end

    add_index :fdn_received_messages, :message_id
    add_index :fdn_received_messages, [:receiver_id, :receiver_type, :trashed_by_receiver, :created_at, :read], :name => 'fdn_received_messages_ind1'
  end
end

