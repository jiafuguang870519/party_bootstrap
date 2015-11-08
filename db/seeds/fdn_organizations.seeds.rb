after :fdn_rights do
  ActiveRecord::Base.connection_pool.with_connection do |c|
    name = 'fdn_organizations'
    #name1 = 'fdn_enterprises'
    name2 = 'fdn_users'
    name3 = 'fdn_roles'
    name4 = 'roles_users'
    name5 = 'rights_roles'
    name6 = 'fdn_depts'
    name7 = 'fdn_homepages'
    name8 = 'fdn_user_informations'

    puts "truncating...#{name}...#{name2}...#{name3}...#{name4}...#{name5}...#{name6}...#{name7}...#{name8}"
    c.execute("truncate table #{name}")

    c.execute("truncate table #{name2}")
    c.execute("truncate table #{name3}")
    c.execute("truncate table #{name4}")
    c.execute("truncate table #{name5}")
    c.execute("truncate table #{name6}")
    c.execute("truncate table #{name7}")
    c.execute("truncate table #{name8}")

    gzw = FactoryGirl.create(:nj_soft_gzw)
    @gzws = Fdn::Dept.first
    @gzw_his = Fdn::DeptHistory.new
    @gzw_his.start_time = '2011-12-31 23:59:59'
    @gzw_his.copy_data(@gzws)

    puts "load completed...#{name}...#{name2}...#{name3}...#{name4}...#{name5}...#{name6}...#{name7}...#{name8}"
  end
end