class CreateFdnOldCodes < ActiveRecord::Migration
  def change
    create_table :fdn_old_codes do |t|
      t.string :code
      t.string :name
      t.string :short_name

      t.timestamps
    end
  end
end
