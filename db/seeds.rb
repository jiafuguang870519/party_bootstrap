#coding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
##确定csv文件目录
#require 'csv'
#directory = File.join(Rails.root, 'db/csv_data')
#
#ActiveRecord::Base.connection_pool.with_connection do |c|
#  name = 'fdn_menus'
#  puts "truncating...#{name}"
#  c.execute("truncate table #{name}")
#  CSV.foreach(directory+'/'+name+'.csv', headers:true) do |row|
#    obj = Fdn::Menu.new row.to_hash.merge!({'created_at'=>'2013-12-10 11:18:40', 'updated_at'=>'2013-12-10 11:18:40'})
#    obj.save(validate: false)
#  end
#
#  puts "load completed...#{name}"
#
#
#  name = 'fdn_rights'
#  c.execute("truncate table #{name}")
#  Fdn::Menu.has_right.each do |m|#.where("not exists (select 1 from fdn_rights where replace(fdn_menus.controller,'/','_') = fdn_rights.type_code and fdn_menus.action = fdn_rights.code)").each do |m|
#    puts "add with menu: #{m.id} , #{m.controller}, #{m.action}"
#    if m.action == 'index'
#      Fdn::Right::COMMON.each do |c|
#        Fdn::Right.create(:type_code => m.controller.gsub(/\//, '_'), :code => c, :app_code => m.controller[0..(m.controller.index('/')-1)], :menu_id => m.id)
#      end
#    else
#      Fdn::Right.create(:type_code => m.controller.gsub(/\//, '_'), :code => m.action, :app_code => m.controller[0..(m.controller.index('/')-1)], :menu_id => m.id)
#    end
#  end
#  puts "load completed...#{name}"
#
#
#  name = 'fdn_organizations'
#  name2 = 'fdn_users'
#  name3 = 'fdn_roles'
#  name4 = 'roles_users'
#  name5 = 'rights_roles'
#  name6 = 'fdn_depts'
#  name7 = 'fdn_homepages'
#  name8 = 'fdn_user_informations'
#
#  puts "truncating...#{name}...#{name2}...#{name3}...#{name4}...#{name5}...#{name6}...#{name7}...#{name8}"
#  c.execute("truncate table #{name}")
#
#  c.execute("truncate table #{name2}")
#  c.execute("truncate table #{name3}")
#  c.execute("truncate table #{name4}")
#  c.execute("truncate table #{name5}")
#  c.execute("truncate table #{name6}")
#  c.execute("truncate table #{name7}")
#  c.execute("truncate table #{name8}")
#
#  gzw = FactoryGirl.create(:nj_soft_gzw)
#  @gzws = Fdn::Dept.first
#  @gzw_his = Fdn::DeptHistory.new
#  @gzw_his.start_time = '2011-12-31 23:59:59'
#  @gzw_his.copy_data(@gzws)
#
#  puts "load completed...#{name}...#{name2}...#{name3}...#{name4}...#{name5}...#{name6}...#{name7}...#{name8}"
#
#  name = 'fdn_org_hierarchies'
#  name2 = 'fdn_org_hie_versions'
#  name3 = 'fdn_org_hie_elements'
#  puts "truncating...#{name}...#{name2}...#{name3}"
#  c.execute("truncate table #{name}")
#  c.execute("truncate table #{name2}")
#  c.execute("truncate table #{name3}")
#
#  gzw = Fdn::Organization.first
#
#  FactoryGirl.create(:cq_org_hierarchy) do |hie|
#    hie.org_hie_elements.create(FactoryGirl.attributes_for(:main_element, p: gzw, r: gzw, c: gzw, d: 0))
#  end
#  FactoryGirl.create(:kb_org_hierarchy) do |hie|
#    hie.org_hie_elements.create(FactoryGirl.attributes_for(:main_element, p: gzw, r: gzw, c: gzw, d: 0))
#  end
#  FactoryGirl.create(:ys_org_hierarchy) do |hie|
#    hie.org_hie_elements.create(FactoryGirl.attributes_for(:main_element, p: gzw, r: gzw, c: gzw, d: 0))
#  end
#  FactoryGirl.create(:nb_org_hierarchy) do |hie|
#    hie.org_hie_elements.create(FactoryGirl.attributes_for(:main_element, p: gzw, r: gzw, c: gzw, d: 0))
#  end
#  FactoryGirl.create(:js_org_hierarchy) do |hie|
#    hie.org_hie_elements.create(FactoryGirl.attributes_for(:main_element, p: gzw, r: gzw, c: gzw, d: 0))
#  end
#
#  by_gov = FactoryGirl.create(:by_gov)
#  xy_gov = FactoryGirl.create(:xy_gov)
#  ny_gov = FactoryGirl.create(:ny_gov)
#  cyzx = FactoryGirl.create(:cyzx)
#
#  @govs = Fdn::Organization.search_dept.other
#  @parent_org = Fdn::Organization.first
#  @depts = Fdn::Dept.govs
#  @depts.each do |gov|
#    @dept_his = Fdn::DeptHistory.new
#    @dept_his.start_time = '2011-12-31 23:59:59'
#    @dept_his.copy_data(gov)
#    @parent_org.with_hierarchy.add_child(gov.organization.id, nil, nil)
#  end
#
#  puts "load completed...#{name}...#{name2}...#{name3}"
#end