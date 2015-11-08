#coding: utf-8
#ActiveRecord::Base.connection_pool.with_connection do |c|
#  name = 'fdn_menus'
#
#  puts "truncating...#{name}..."
#  c.execute("truncate table #{name}")
#
#  FactoryGirl.createlist(:fdn_menu)
#
#  puts "load completed...#{name}..."
#end
#确定csv文件目录
require 'csv'
directory = File.join(Rails.root, 'db/csv_data')

ActiveRecord::Base.connection_pool.with_connection do |c|
  name = 'fdn_menus'
  puts "truncating...#{name}"
  c.execute("truncate table #{name}")
  CSV.foreach(directory+'/'+name+'.csv', headers:true) do |row|
    obj = Fdn::Menu.new row.to_hash.merge!({'created_at'=>'2013-12-10 11:18:40', 'updated_at'=>'2013-12-10 11:18:40'})
    obj.save(validate: false)
  end

  puts "load completed...#{name}"
end