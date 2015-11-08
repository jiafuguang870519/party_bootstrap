class CreateFdnWidgets < ActiveRecord::Migration
  def change
    create_table :fdn_widgets do |t|
      t.string :name
      t.string :code
      t.string :url
      t.string :title
      t.integer :bold
      t.integer :higher
      t.string :params

      t.timestamps
      t.tracer
    end

    add_index :fdn_widgets, :code
  end
end
