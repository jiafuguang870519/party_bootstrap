class CreateFdnLoggers < ActiveRecord::Migration
  def change
    create_table :fdn_loggers do |t|
      t.integer :user_id
      t.string :ip, :limit=>20
      t.string :controller, :limit=>100
      t.string :action, :limit=>100
      t.datetime :act_at
    end

    add_index :fdn_loggers, :user_id
    add_index :fdn_loggers, [:controller, :action], :name => 'fdn_loggers_ind1'
  end
end
