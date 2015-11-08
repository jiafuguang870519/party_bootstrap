after :fdn_menus do
  ActiveRecord::Base.connection_pool.with_connection do |c|
    name = 'fdn_rights'
    c.execute("truncate table #{name}")
    Fdn::Menu.has_right.each do |m|#.where("not exists (select 1 from fdn_rights where replace(fdn_menus.controller,'/','_') = fdn_rights.type_code and fdn_menus.action = fdn_rights.code)").each do |m|
      puts "add with menu: #{m.id} , #{m.controller}, #{m.action}"
      if m.action == 'index'
        Fdn::Right::COMMON.each do |c|
          Fdn::Right.create(:type_code => m.controller.gsub(/\//, '_'), :code => c, :app_code => m.controller[0..(m.controller.index('/')-1)], :menu_id => m.id)
        end
      else
        Fdn::Right.create(:type_code => m.controller.gsub(/\//, '_'), :code => m.action, :app_code => m.controller[0..(m.controller.index('/')-1)], :menu_id => m.id)
      end
    end
    puts "load completed...#{name}"

  end
end