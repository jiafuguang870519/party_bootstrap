json.array!(@fdn_menus) do |fdn_menu|
  json.extract! fdn_menu[0], :id
  json.text fdn_menu[0].name
  json.code fdn_menu[0].code
  json.description fdn_menu[0].description
  json.title_img fdn_menu[0].title_img
  json.parent_name fdn_menu[0].parent.name
  json.controller fdn_menu[0].controller
  json.action fdn_menu[0].action
  json.status fdn_menu[0].status
  json.tags [fdn_menu[0].children_count]
  unless fdn_menu[1].empty?
      json.nodes fdn_menu[1] do |node|
        json.id node[0].id
        json.text node[0].name
        json.code node[0].code
        json.description node[0].description
        json.title_img node[0].title_img
        json.parent_name node[0].parent.name
        json.controller node[0].controller
        json.action node[0].action
        json.status node[0].status
        json.tags [node[0].children_count]
        unless node[1].empty?
          json.nodes node[1] do |subnode|
            json.id subnode[0].id
            json.text subnode[0].name
            json.code subnode[0].code
            json.description subnode[0].description
            json.title_img subnode[0].title_img
            json.parent_name subnode[0].parent.name
            json.controller subnode[0].controller
            json.action subnode[0].action
            json.status subnode[0].status
          end
        end
      end
  end
end
