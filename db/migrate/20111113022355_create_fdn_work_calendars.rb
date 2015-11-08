class CreateFdnWorkCalendars < ActiveRecord::Migration
  def change
    create_table :fdn_work_calendars do |t|
      t.integer :year
      t.integer :qtr
      t.integer :month
      t.integer :day_of_week
      t.date :day_name
      t.integer :is_working
      t.integer :is_weekend
      t.integer :is_holiday

      t.timestamps
    end

    add_index :fdn_work_calendars, [:year, :month], :name=>'fdn_work_calendars_ind1'
  end
end
