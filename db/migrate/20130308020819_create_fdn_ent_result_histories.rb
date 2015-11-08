class CreateFdnEntResultHistories < ActiveRecord::Migration
  def change
    create_table :fdn_ent_result_histories do |t|
      t.integer  :ent_id
      t.integer  :row_template_id
      t.decimal  :value,           :precision => 20, :scale => 2
      t.integer  :lock_version
      t.datetime :created_at,                                     :null => false
      t.datetime :updated_at,                                     :null => false
      t.integer  :created_by
      t.integer  :updated_by
      t.decimal :exchange_rate ,:precision=>20, :scale=>2
      t.decimal :foreign_currency ,:precision=>20, :scale=>2
      t.integer :currency_code
      t.decimal :ent_declare_value, :precision => 20, :scale => 2
      t.decimal :app_value, :precision => 20, :scale => 2
      t.decimal :last_reg_value, :precision => 20, :scale => 2
    end
  end
end
