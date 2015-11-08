class CreateFdnWidgetActions < ActiveRecord::Migration
  def change
    create_table :fdn_widget_actions do |t|
      t.integer :widget_id
      t.string :value
      t.string :icon
      t.text :href
      t.text :onclick

      t.timestamps
    end

    add_index :fdn_widget_actions, :widget_id
  end
end
