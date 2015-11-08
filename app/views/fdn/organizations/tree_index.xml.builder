xml.instruct!
xml.rows do
  xml.page 1
  xml.total 1
  xml.records 1
  n_lvl = params[:n_level] ? params[:n_level].to_i+1 : 0
  for organization in @fdn_organizations
    xml.row do
      #xml.cell organization.id
      xml.cell organization.id
      xml.cell "<div class='context-menu-sub box menu-1' id='#{organization.id}'>"+organization.name+organization.using_tree(@eff_time)+"</div>"
      xml.cell organization.code
      xml.cell organization.using_tree(@eff_time) #organization.org_type_name
      xml.cell '123' #link_to "历史记录" ,url_for(show_history_fdn_organizations_path(:id=>organization.id))
                                                  #if organization.resource_type == 'Fdn::Dept'
                                                  #  xml.cell (organization.status == 'Y' ? "--" : "--")
                                                  #else
                                                  #  #xml.cell (organization.status == 'Y' ? "<div class='green'>已启用</div>" : "<div class='red'>已停用</div>")
                                                  #  #xml.cell "<div class=#{organization.status== 'Y' ? 'green' : 'red'} >"+(link_to (organization.status== 'Y' ? "已启用" : "已停用") ,url_for(add_or_delete_fdn_organizations_path(:id=>organization.id)))+"</div>"
                                                  #  xml.cell (organization.status == 'Y' ? "已启用" : "已停用")
                                                  #end
      xml.cell '123123'
      xml.cell n_lvl

      organization.with_hierarchy(@hierarchy_id, @eff_time)
      parent_org = organization.parent
      if parent_org.blank?
        valp = 'NULL'
      else
        valp = parent_org.id
      end
      xml.cell valp
      if organization.children.blank?
        leaf = 'true'
      else
        leaf = 'false'
      end
      xml.cell leaf
      xml.cell 'false'
    end
  end
  #if @nodeid.blank?
  if @nodeid.blank?
    xml.row do
      #xml.cell organization.id
      xml.cell 99999
      xml.cell "<div class='context-menu-sub box menu-1' id=''>尚未关联的企业</div>"
      xml.cell ''
      xml.cell '' #organization.org_type_name
      xml.cell '' #link_to "历史记录" ,url_for(show_history_fdn_organizations_path(:id=>organization.id))
                  #if organization.resource_type == 'Fdn::Dept'
                  #  xml.cell (organization.status == 'Y' ? "--" : "--")
                  #else
                  #  #xml.cell (organization.status == 'Y' ? "<div class='green'>已启用</div>" : "<div class='red'>已停用</div>")
                  #  #xml.cell "<div class=#{organization.status== 'Y' ? 'green' : 'red'} >"+(link_to (organization.status== 'Y' ? "已启用" : "已停用") ,url_for(add_or_delete_fdn_organizations_path(:id=>organization.id)))+"</div>"
                  #  xml.cell (organization.status == 'Y' ? "已启用" : "已停用")
                  #end
      xml.cell ''
      xml.cell 0
      xml.cell 'NULL'
      xml.cell 'false'
      xml.cell 'false'
      for organization in @other_orgs
        xml.row do
          #xml.cell organization.id
          xml.cell organization.id
          xml.cell "<div class='context-menu-sub box menu-1' id='#{organization.id}'>"+organization.name+organization.using_tree(@eff_time)+"</div>"
          xml.cell organization.code
          xml.cell organization.using_tree(@eff_time) #organization.org_type_name
          xml.cell '123' #link_to "历史记录" ,url_for(show_history_fdn_organizations_path(:id=>organization.id))
                                                      #if organization.resource_type == 'Fdn::Dept'
                                                      #  xml.cell (organization.status == 'Y' ? "--" : "--")
                                                      #else
                                                      #  #xml.cell (organization.status == 'Y' ? "<div class='green'>已启用</div>" : "<div class='red'>已停用</div>")
                                                      #  #xml.cell "<div class=#{organization.status== 'Y' ? 'green' : 'red'} >"+(link_to (organization.status== 'Y' ? "已启用" : "已停用") ,url_for(add_or_delete_fdn_organizations_path(:id=>organization.id)))+"</div>"
                                                      #  xml.cell (organization.status == 'Y' ? "已启用" : "已停用")
                                                      #end
          xml.cell '123123'
          xml.cell 1
          xml.cell 99999
          xml.cell 'true'
          xml.cell 'false'
        end
      end
    end
  end
end