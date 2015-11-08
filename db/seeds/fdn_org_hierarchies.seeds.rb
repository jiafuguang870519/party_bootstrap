after :fdn_organizations do
  ActiveRecord::Base.connection_pool.with_connection do |c|
    name = 'fdn_org_hierarchies'
    name2 = 'fdn_org_hie_versions'
    name3 = 'fdn_org_hie_elements'
    puts "truncating...#{name}...#{name2}...#{name3}"
    c.execute("truncate table #{name}")
    c.execute("truncate table #{name2}")
    c.execute("truncate table #{name3}")

    gzw = Fdn::Organization.first

    FactoryGirl.create(:cq_org_hierarchy) do |hie|
      hie.org_hie_elements.create(FactoryGirl.attributes_for(:main_element, p: gzw, r: gzw, c: gzw, d: 0))
    end
    # FactoryGirl.create(:kb_org_hierarchy) do |hie|
    #   hie.org_hie_elements.create(FactoryGirl.attributes_for(:main_element, p: gzw, r: gzw, c: gzw, d: 0))
    # end
    # FactoryGirl.create(:ys_org_hierarchy) do |hie|
    #   hie.org_hie_elements.create(FactoryGirl.attributes_for(:main_element, p: gzw, r: gzw, c: gzw, d: 0))
    # end
    # FactoryGirl.create(:nb_org_hierarchy) do |hie|
    #   hie.org_hie_elements.create(FactoryGirl.attributes_for(:main_element, p: gzw, r: gzw, c: gzw, d: 0))
    # end
    # FactoryGirl.create(:js_org_hierarchy) do |hie|
    #   hie.org_hie_elements.create(FactoryGirl.attributes_for(:main_element, p: gzw, r: gzw, c: gzw, d: 0))
    # end

    #FactoryGirl.attributes_for(:one_lvl).create_organization(FactoryGirl.attributes_for(:one_lvl_org1))
    #FactoryGirl.attributes_for(:one_lvl_other).create_organization(FactoryGirl.attributes_for(:one_lvl_org2))
    #FactoryGirl.attributes_for(:two_lvl).create_organization(FactoryGirl.attributes_for(:two_lvl_org))
    #
    #gzw.with_hierarchy.add_child(2,nil,nil)
    #gzw.with_hierarchy.add_child(3,nil,nil)
    #gzw.with_hierarchy.add_child(4,nil,nil)

    puts "load completed...#{name}...#{name2}...#{name3}"
  end
end