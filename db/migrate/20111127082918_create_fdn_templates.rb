class CreateFdnTemplates < ActiveRecord::Migration
  def change
    create_table :fdn_templates do |t|
      t.string :name
      t.string :code
      t.text :content, :limit=> 2.megabytes
      t.integer :menu_id
      t.timestamps
    end

    add_index :fdn_templates, :menu_id
    add_index :fdn_templates, :code
  end
end
