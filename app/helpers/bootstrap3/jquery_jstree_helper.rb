#coding: utf-8
module Bootstrap3::JqueryJstreeHelper

  def jstree_include_tag
    javascript_include_tag('/js/plugins/jsTree/jstree.min.js')
  end

  #在新的jstree3.1.1中，取消了xml数据，所以新的树用json
  #obj_id：div的id
  #remote_url：点击树时，调用ajax方法的路径，
  #use_id：调用ajax方法时，接收树对象id的参数名称
  #search：true/false  是否带有查询功能
  #search_id：查询输入框的id
  def js_tree_org_json_tag(obj_id,remote_url,use_id,search,search_id)
    script = Array.new
    script << "$('##{obj_id}').on('changed.jstree', function (e, data) {"
    script << "    var i, j, r ;"
    script << "    for(i = 0, j = data.selected.length; i < j; i++) {"
    script << "      r = data.instance.get_node(data.selected[i]).id;"
    script << "    }"
    script << "    if (r != 9999 && r!=99999){"
    script << "        $.jq_remote_get('#{remote_url}',{'#{use_id}': r, format : 'js'});"
    script << "    }"
    script << "  }).jstree({"
    script << "    'core': {"
    script << "        'multiple' : false,"
    script << "        'data': {"
    script << "            'url': function (node) {"
    script << "                  return '/fdn/roles/org_tree.json?org_id='+node.id;"
    script << "                },"
    script << "            'data': function (node) {"
    script << "                return { 'id': node.id };"
    script << "            }"
    script << "        },"
    script << "        'dblclick_toggle': false"
    script << "    },"
    script << "    'plugins' : [ #{search == false ? '' : '\'search\''}]"
    script << ""
    script << "});"
    script << "#{(search == false ? '' : generate_js_tree_search(obj_id,search_id))}"
    javascript_tag(script.join("\n"))
  end

  def generate_js_tree_search(obj_id,search_id)
    js = <<-SEARCH_JS
      $(function () {
        var to = false;
        $('##{search_id}').keyup(function () {
          if(to) { clearTimeout(to); }
            to = setTimeout(function () {
            var v = $('##{search_id}').val();
            $('##{obj_id}').jstree(true).search(v);
          }, 250);
        });
      });
    SEARCH_JS
  end

  #html转变为jstree显示
  #html 格式如下：
  #<li id='root'><a href='#'>Root node</a>
  #  <ul>
  #    <li><a href='#'>Root node</a>
  #      <ul><li><a href='#'>Child node</a></li></ul>
  #    </li>
  #  </ul>
  #</li>
  #<%= js_tree_html_tag('root', 'alert(1);') %>

  def js_tree_html_tag(obj_id, onclick='', tree_theme=nil)
    theme = tree_theme || 'classic'
    script = Array.new
    script << "$(function () {"
    script << "   $('##{obj_id}').jstree({ "
    script << "       #{generate_js_tree_types()}"
    script << "     'themes' : { 'theme' : '#{theme}', 'dots' : false},"
    script << "     'plugins' : [ 'themes', 'html_data', 'dnd', 'ui', 'types' ]"
    script << "   }).bind('select_node.jstree', function (event, data) {#{onclick}});"
    script << "});"
    javascript_tag(script.join("\n"))
  end

  #XML动态加载jstree
  def js_tree_xml_tag(obj_id, xml_url, onclick='', menu_ajax_url='', tree_theme=nil, checkbox=false, checkbox_js="", not_auto_check=true)
    theme = tree_theme || 'classic'
    checkbox = checkbox || false
    #选择父自动全选所有子节点
    attr_two_state = not_auto_check ? ",'two_state' : 'true'" : ""
    script = Array.new
    script << "$(function () {"
    script << "   $('##{obj_id}').jstree({"
    script << "       #{generate_js_tree_types()}"
    script << "       'xml_data' : {"
    script << "           'ajax' : {"
    script << "               'url' : '#{xml_url}',"
    script << "               'data' : function (n) {"
    script << "                   return {"
    script << "                       id : n.attr ? n.attr('id') : 0,"
    script << "                       root_id : n.attr ? n.attr('root_id') : 0,"
    script << "                       class_id : n.attr ? n.attr('class_id') : 0,"
    script << "                       rand : new Date().getTime()"
    script << "                   };"
    script << "               }"
    script << "           }"
    script << "       },"
    script << "       #{(menu_ajax_url == '' ? '' : generate_js_tree_contextmenu_item)}"
    script << "       'themes': { 'theme' : '#{theme}', 'dots' : false},"
    script << "       'plugins' : [ 'themes', 'xml_data', 'ui', 'dnd', 'types', 'crrm' #{menu_ajax_url == '' ? '' : ',\'contextmenu\''} #{checkbox == false ? '' : ',\'checkbox\''} ],"
    script << "       'checkbox': {'override_ui' : 'true' #{attr_two_state}}"
    script << "   })"
    script << "   #{(onclick == '' ? '' : generate_js_tree_click(onclick))}"
    script << "   #{(menu_ajax_url == '' ? '' : generate_js_tree_contextmenu_ajax(menu_ajax_url))}"
    script << "   #{(checkbox_js == '' ? '' : generate_js_checkbox(checkbox_js))}"
    script << "});"
    javascript_tag(script.join("\n"))
  end

  #XML动态加载组织树jstree
  def js_tree_for_org_xml_tag(obj_id, xml_url, onclick='', menu_ajax_url='', current_rel_id = '', tree_theme=nil, checkbox=false, checkbox_js="", not_auto_check=true)
    theme = tree_theme || 'classic'
    checkbox = checkbox || false
    #选择父自动全选所有子节点
    attr_two_state = not_auto_check ? ",'two_state' : 'true'" : ""
    script = Array.new
    script << "$(function () {"
    script << "   $('##{obj_id}').jstree({"
    script << "       #{generate_js_tree_types_for_org()}"
    script << "       'xml_data' : {"
    script << "           'ajax' : {"
    script << "               'url' : '#{xml_url}',"
    script << "               'data' : function (n) {"
    script << "                   return {"
    script << "                       id : n.attr ? n.attr('id') : 0,"
    script << "                       rand : new Date().getTime()"
    script << "                   };"
    script << "               }"
    script << "           }"
    script << "       },"
    script << "       #{(menu_ajax_url == '' ? '' : generate_js_tree_contextmenu_item_for_org)}"
    script << "       'themes': { 'theme' : '#{theme}', 'dots' : false},"
    script << "       'plugins' : [ 'themes', 'xml_data', 'ui', 'dnd', 'types', 'crrm' #{menu_ajax_url == '' ? '' : ',\'contextmenu\''} #{checkbox == false ? '' : ',\'checkbox\''} ],"
    script << "       'core' : { 'initially_open' : [ 'root' ,'#{current_rel_id}'] },"
    script << "       'checkbox': {'override_ui' : 'true' #{attr_two_state}}"
    script << "   })"
    script << "   #{(onclick == '' ? '' : generate_js_tree_click(onclick))}"
    script << "   #{(menu_ajax_url == '' ? '' : generate_js_tree_contextmenu_ajax_for_org(menu_ajax_url))}"
    script << "   #{(checkbox_js == '' ? '' : generate_js_checkbox(checkbox_js))}"
    script << "});"
    javascript_tag(script.join("\n"))
  end

  private

  #个性化图标
  def generate_js_tree_types_for_org()
    js= <<-TYPES_JS
        'types' : {
            "valid_children" : [ "root" ],
            'types' : {
                'element' : {
                    'icon' : {
                        'image' : '#{image_path("themes/default/icons/status_online.png")}'
                    }
                },
                'root' : {
                    'icon' : {
                        'image' : '#{image_path("themes/default/icons/house.png")}'
                    },
                    "move_node" : false,
                    "delete_node" : false,
                    "remove" : false
                }
            }
        },
    TYPES_JS
  end

  #个性化图标
  def generate_js_tree_types()
    js= <<-TYPES_JS
        'types' : {
            "valid_children" : [ "root" ],
            'types' : {
                'user' : {
                    'icon' : {
                        'image' : '#{image_path("themes/default/icons/status_online.png")}'
                    }
                },
                'dept' : {
                    'icon' : {
                        'image' : '#{image_path("themes/default/icons/house.png")}'
                    }
                },
                'right' : {
                    'icon' : {
                        'image' : '#{image_path("themes/default/icons/cog.png")}'
                    }
                },
                'book' : {
                    'icon' : {
                        'image' : '#{image_path("themes/default/icons/book.png")}'
                    }
                },
                'package' : {
                    'icon' : {
                        'image' : ''
                    }
                }
            }
        },
    TYPES_JS
  end

  def generate_js_tree_click(js)
    js = <<-MENU_JS

          .bind("select_node.jstree", function (event, data) {
            #{js}
          })
    MENU_JS
  end

  def generate_js_checkbox(js)
    js = <<-MENU_JS

          .bind("change_state.jstree", function (e, d) {

            if ((d.args[0].tagName == "A" || d.args[0].tagName == "INS") && (d.inst.data.core.refreshing != true && d.inst.data.core.refreshing != "undefined")) {
                //if (d.args[0].tagName == "INS"){
                    #{js}
                //}
            }
          })
    MENU_JS
  end

  def generate_js_tree_contextmenu_item
    js = <<-MENU_JS
      'contextmenu': {
          'items': {
              'create': {
                  'label': '新建',
                  'separator_before'	: false,
                  'separator_after'	: true,
                  'action' : function (obj) { this.create(obj); }
              },
              'rename': {
                  'label': '改名',
                  'separator_before'	: false,
                  'separator_after'	: false,
                  'action' : function (obj) { this.rename(obj); }
              },
              'remove': {
                  'label': '删除',
                  'separator_before'	: false,
                  'separator_after'	: false,
                  'icon': false,
                  'action' : function (obj) { if(this.is_selected(obj)) { this.remove(); } else { this.remove(obj); } }
              },
              'ccp': null
          }
      },
    MENU_JS
  end


  def generate_js_tree_contextmenu_item_for_org
    js = <<-MENU_JS
      'contextmenu': {
          'items': {
              'create': {
                  'label': '新建',
                  'separator_before'	: false,
                  'separator_after'	: true,
                  'action' : function (obj) {top.showCloseModal("组织选择","fdn/organizations/search_org/1?node_id="+obj.attr("id").replace("li_", "")+"&hie_id="+ obj.attr("hie_id").replace("li_", "")+"&action_name=treeload_create","400","200",closeModalOnClose)}
              },
              'rename': {
                  'label': '修改',
                  'separator_before'	: false,
                  'separator_after'	: false,
                  'action' : function (obj) {top.showCloseModal("组织选择","fdn/organizations/search_org/1?node_id="+obj.attr("id").replace("li_", "")+"&hie_id="+ obj.attr("hie_id").replace("li_", "")+"&action_name=treeload_rename","400","200",closeModalOnClose) }
              },
              'remove': {
                  'label': '删除',
                  'separator_before'	: false,
                  'separator_after'	: false,
                  'icon': false,
                  'action' : function (obj) { if(this.is_selected(obj)) { this.remove(); } else { this.remove(obj); } }
              },
              'ccp': null
          }
      },
    MENU_JS
  end

  def generate_js_tree_contextmenu_ajax(url_ajax)
    url_create = url_ajax+ '_create'
    url_remove = url_ajax+ '_remove'
    url_rename = url_ajax+ '_rename'
    js = <<-MENU_JS

          .bind("create.jstree", function (e, data) {
              var createdata = "";
                    createdata += "node_name=" + data.rslt.name;
                    createdata += "&parent_id=" + parseInt(data.rslt.parent.attr('id').replace('li_', ''));
                    createdata += '&root_id=' + parseInt(data.rslt.parent.attr("root_id").replace("li_", ""));
                    createdata += '&class_id=' + parseInt(data.rslt.parent.attr("class_id").replace("li_", ""));
              var jqxhr = $.post("#{url_create}", createdata, function() {
                
              })
              .success(function(data1) {
                  $(data.rslt.obj).attr("root_id", "li_" + data1);
                  $(data.rslt.obj).attr("class_id", "li_" + parseInt(data.rslt.parent.attr("class_id").replace("li_", "")));
                  $(data.rslt.obj).attr("id", "li_" + data1);
              })
              .error(function() {
                  alert("权限问题，您的创建失败，请与管理员联系！");
                  $.jstree.rollback(data.rlbk);
              });
          })
          .bind("remove.jstree", function (e, data) {
              var removedata = "";
                    removedata += "node_id=" + parseInt(data.rslt.obj.attr('id').replace('li_', ''));
              var jqxhr = $.post("#{url_remove}", removedata, function() {

              })
              .success(function(data1) {
                  if(data1.toString() != '1'){
                      alert("非空目录不允许删除");
                      $.jstree.rollback(data.rlbk);
                  }
              })
              .error(function() {
                  alert("删除失败");
                  $.jstree.rollback(data.rlbk);
              });
          })
          .bind("rename.jstree", function (e, data) {
              var newName = data.rslt.new_name;
              if (newName != "" && newName != undefined) {
                  var renamedata = "";
                        renamedata += "node_id=" + parseInt(data.rslt.obj.attr('id').replace('li_', ''));
                        renamedata += "&node_name=" + newName;

                  var jqxhr = $.post("#{url_rename}", renamedata, function() {

                  })
                  .success(function(data1) {
                  })
                  .error(function() {
                      alert("权限问题，您的重命名失败，请与管理员联系！");
                      $.jstree.rollback(data.rlbk);
                  });
              }
          })
         
    MENU_JS
  end

  def generate_js_tree_contextmenu_ajax_for_org(url_ajax)
    url_create = url_ajax+ '_create'
    url_remove = url_ajax+ '_remove'
    url_rename = url_ajax+ '_rename'
    url_move_node = url_ajax+ '_move_node'
    js = <<-MENU_JS

          .bind("create.jstree", function (e, data) {
              var createdata = "";
                    createdata += "node_name=" + data.rslt.name;
                    createdata += '&node_id=' + parseInt(data.rslt.obj.attr("id").replace("li_", ""));
                    createdata += '&hie_id=' + parseInt(data.rslt.obj.attr("hie_id").replace("li_", ""));
                    var jqxhr = $.post("#{url_create}", createdata, function() {

              })
              .success(function(data1) {
                  $(data.rslt.obj).attr("root_id", "li_" + data1);
                  $(data.rslt.obj).attr("class_id", "li_" + parseInt(data.rslt.parent.attr("class_id").replace("li_", "")));
                  $(data.rslt.obj).attr("id", "li_" + data1);
              })
              .error(function() {
                  alert("保存失败");
                  $.jstree.rollback(data.rlbk);
              });
          })
          .bind("remove.jstree", function (e, data) {
              var removedata = "";
              removedata += "node_id=" + parseInt(data.rslt.obj.attr('id').replace('li_', ''));
              removedata += "&hie_id=" + parseInt(data.rslt.obj.attr('hie_id').replace('li_', ''));
              var jqxhr = $.post("#{url_remove}", removedata, function() {

              })
              .success(function(data1) {
                  if(data1.toString() != '1'){
                      alert("非空目录不允许删除");
                      $.jstree.rollback(data.rlbk);
                  }
              })
              .error(function() {
                  alert("删除失败");
                  $.jstree.rollback(data.rlbk);
              });
          })

           .bind("move_node.jstree", function (e, data) {
                data.rslt.o.each(function (i) {
                var movedata = "";
               if(data.rslt.np.attr('id')=='root'){
                alert("禁止移动");
                $.jstree.rollback(data.rlbk);}
else{
              if(confirm("您确认要移动吗？"))
               {
                movedata += "node_id=" + parseInt(this.id.replace('li_', ''));
                movedata += "&parent_id=" + parseInt(data.rslt.np.attr('id').replace('li_', ''));
                movedata += '&hie_id=' + parseInt(data.rslt.np.attr("hie_id").replace("li_", ""));
                movedata += '&seq='+ parseInt(data.rslt.o.index());
                var jqxhr = $.post("#{url_move_node}", movedata, function() {
                })
                 .success(function(data1) {
                   if(data1.toString() != '1'){
                        alert("移动失败");
                        $.jstree.rollback(data.rlbk);
                       }
                   })
                  .error(function() {
                     alert("移动失败");
                   $.jstree.rollback(data.rlbk);
                   });
                 }
            else{$.jstree.rollback(data.rlbk);}
}
      })
                 })

          .bind("rename.jstree", function (e, data) {
              var newName = data.rslt.new_name;
              if (newName != "" && newName != undefined) {
                  var renamedata = "";
                        renamedata += "node_id=" + parseInt(data.rslt.obj.attr('id').replace('li_', ''));
                        renamedata += '&hie_id=' + parseInt(data.rslt.obj.attr("hie_id").replace("li_", ""));
                        renamedata += "&node_name=" + newName;

                  var jqxhr = $.post("#{url_rename}", renamedata, function() {

                  })
                  .success(function(data1) {
                  })
                  .error(function() {
                      alert("重命名失败");
                      $.jstree.rollback(data.rlbk);
                  });
              }
          })
          
    MENU_JS
  end
end
