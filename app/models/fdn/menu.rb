module Fdn
  class Menu < ActiveRecord::Base
    HOME_MENU = 'home'
    DIVIDER_MENU = 'divider'
    PROCESS_MENU = 'process'
    WORKSPACE_MENU = 'workspace'

    ALWAYS_SHOW_MENU = ['home','workspace','divider','process','dashboard','project',
                        'wiki','communication','notification','recycling',"financial_statement"]

    #选择权限时 不在企业端显示的菜单
    ENT_NENUS = []

    attr_accessor :parent_name

    validates_presence_of :code,:parent_id

    scope :home, -> { where("code='home'") }
    scope :ex_home, -> { where("code <> 'home'") }
    scope :active, -> { where("status='Y'") }
    scope :top_level, -> { where("parent_id = 1").order('position') }
    scope :has_children, -> { where("children_count != 0") }
    scope :has_parent, -> { where("parent_id is not null") }
    scope :has_right, -> { ex_home.where("controller not in ('wf/processes' , 'workspaces') and controller is not null and controller != '' and action is not null and action != ''") }
    scope :not_in, lambda { |ids| where('fdn_menus.id not in (?)', ids) }
    scope :parent_not_in, lambda { |ids| where('fdn_menus.parent_id not in (?)', ids) }

    acts_as_ordered_tree

    def self.build_menu(current_user)
      is_true=0
      is_true=1 if (current_user.is_a_WLD?)||(current_user.is_a_ZGWLD?)||(current_user.is_a_FGWLD?)
      items = []
      i = 1
      top_menus = Fdn::Menu.where(depth: 1)
      top_menus.each do |m|
        #logger.info(m.inspect)
        items << m.menu_to_html(current_user, true, i == top_menus.size)
        i += 1
      end
      items.delete_if { |i| i.blank? }
    end

    def menu_to_html(current_user, top=false, is_last_top=false)
      #home和工作列表不需要授权
      if Fdn::Menu::ALWAYS_SHOW_MENU.include?(code)
        menu_html_str current_user, top, is_last_top
      else
        #logger.info("m:#{code},#{controller},#{action}")
        #logger.info("u:#{current_user.id}")
        #logger.info("can_#{action}_#{tc(controller)}?")
        #如果本身有设置controller和action则判断权限，否则判断子菜单的权限，如有任一子菜单的权限，则主菜单也显示
        if !controller.blank? && !action.blank?
          #logger.info("no blank")
          return '' unless current_user.send("can_#{action}_#{tc(controller)}?")
          menu_html_str current_user, top, is_last_top
        else
          no_right = true
          descendants.each do |d|
            #logger.info("d:#{d.code},#{d.controller},#{d.action}")
            #logger.info("can_#{d.action}_#{tc(d.controller)}?")
            if !d.controller.blank? && !d.action.blank? && current_user.send("can_#{d.action}_#{tc(d.controller)}?")
              #logger.info("has right")
              no_right = false
              break
            end
          end
          #logger.info("no_right:#{no_right}")
          if no_right
            return ''
          else
            menu_html_str current_user, top, is_last_top
          end
        end
      end
    end

    def menu_html_str(current_user, top=false, is_last_top=false)
      items = []
      children.reject { |c| c.status != "Y" }.each do |c|
        str = c.menu_to_html(current_user)
        items << str if !str.blank?
      end
      if !items.blank?
        item_str = "<ul class='nav' id='side-menu'>" + items.join + "</ul>"
        #if top
        #  item_str = "<ul><li class='arrow'></li>" + items.join + "</ul>"
        #else
        #  item_str = "<ul>" + items.join + "</ul>"
        #end
      end
      if !controller.blank? && !action.blank?
        if action == 'index' && !['main', 'workspaces'].include?(controller)
          url = "/#{controller}/"
        else
          url = "/#{controller}/#{action}"
        end
        #图片
        if ['show', 'edit'].include?(action)
          url += "/#{params}" if !params.blank?
        else
          url += "?#{params}" if !params.blank?
        end
      end
      #菜单分隔线
      if code == Fdn::Menu::DIVIDER_MENU
        return "<li class='seperator'><a href='#'></a></li>"
      else
        if top
          #判断是否有下级菜单
          if item_str.blank?
            #logger.info("menu: #{name} is_last: #{is_last_top}")
            return "<li><a href='#{url}'  id='#{code}'><i class='fa fa-#{title_img.blank? ? 'gear' : title_img}'></i> #{name}</a></li>" #+ (is_last_top ? "" : "<li class='spacer'><span>|</span></li>")
          else
            return "<li><a href='#{url}'  id='#{code}'><i class='fa fa-#{title_img.blank? ? 'gear' : title_img}'></i> #{name}<span class='fa arrow'></span></a>#{item_str}</li>" #+ (is_last_top ? "" : "<li class='spacer'><span>|</span></li>")
          end
        else
          #判断是否有下级菜单
          if item_str.blank?
            return "<li ><a href='#{url}' id='#{code}'>#{name}</a></li>"
          else
            return "<li ><a href='#{url}' id='#{code}'>#{name}<span class='fa arrow'></span></a>#{item_str}</li>"
          end
        end
      end
    end

    private
    def tc(c_name)
      c_name.gsub(/\//, '_')
    end
  end
end