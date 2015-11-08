class CreateFdnFileResources < ActiveRecord::Migration
  def change
    create_table :fdn_file_resources do |t|
      t.integer :resource_id
      t.string :resource_type
      t.integer :ffx_file_size
      t.string :ffx_content_type
      t.string :ffx_file_name
      t.string :display_name
      t.string :status
      t.string :file_desc
      t.integer :file_class_id

      t.timestamps
    end

    add_index :fdn_file_resources, [:resource_id, :resource_type, :file_class_id], :name=>'fdn_file_resources_ind1'
  end
end
