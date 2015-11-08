class CreateFdnDeptHistories < ActiveRecord::Migration
  def change
    create_table :fdn_dept_histories do |t|
      t.integer  :dept_id
      t.datetime :start_time
      t.datetime :end_time
      t.integer  :seq
      t.integer  :internal
      t.string   :type_code
      t.datetime :start_time

      t.timestamps
    end
  end
end
