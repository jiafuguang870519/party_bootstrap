class CreateFdnEntResults < ActiveRecord::Migration
  def change
    create_table :fdn_ent_results do |t|
      t.integer :ent_id
      t.integer :row_template_id
      t.decimal :value, :precision=>20, :scale=>2
      t.integer :lock_version
      t.decimal :exchange_rate ,:precision=>20, :scale=>2
      t.decimal :foreign_currency ,:precision=>20, :scale=>2
      t.integer :currency_code
      t.decimal :ent_declare_value, :precision => 20, :scale => 2
      t.decimal :app_value, :precision => 20, :scale => 2
      t.decimal :last_reg_value, :precision => 20, :scale => 2

      t.timestamps
      t.tracer
    end

    add_index :fdn_ent_results, :ent_id
    add_index :fdn_ent_results, :row_template_id
  end
end
