class CreateFdnUserGroups < ActiveRecord::Migration
  def change
    create_table :fdn_user_groups do |t|
      t.string :name
      t.string :contact_ids
      t.timestamps
      t.tracer
    end

    add_index :fdn_user_groups, :created_by
  end
end
