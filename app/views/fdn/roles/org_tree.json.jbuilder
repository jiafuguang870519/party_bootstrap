json.array!(@orgs) do |org|
    json.id org.id
    if org.children.empty?
        json.children false
    else
        json.children true
    end
    json.text org.name+org.using_tree(Time.now)
    json.code org.code
end
if @org_id.blank?
    json.array!(@other_orgs) do |r|
     json.id 9999
     json.children true
     json.text '尚未关联的企业'
        unless @other_orgs.empty?
            json.children(@other_orgs) do |o_org|
                json.id o_org.id
                json.children false
                json.text o_org.name+o_org.using_tree(Time.now)
                json.code o_org.code
            end
        end
    end
    json.array!(@other_orgs) do
     json.id 99999
     json.children false
     json.text '区县国资委'
    end
end