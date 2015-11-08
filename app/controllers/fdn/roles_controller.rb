#coding: utf-8
module Fdn
  class RolesController < ApplicationController
    before_action :set_fdn_role, only: [:show, :edit, :update, :destroy]
    def autocomplete_organization_id
      @orgs = Fdn::Organization.where("name like ?", "%#{params[:term]}%")
      respond_to do |format|
        format.json { render :json => CustomJson.autocomplete_json(@orgs, ["id", "name", "name"]) }
      end
    end

    def index
      @search = Fdn::Role.search(params[:q])
      @org_id = !params[:org_id].blank? ? params[:org_id] : session[:org_id]
      #@org = Fdn::Organization.find(@org_id)
      #if current_user.is_a_super_administrator?
      #  @roles = Fdn::Role.paginate(:page => params[:page])
      #else
      #  @roles = Fdn::Role.where(:organization_id=> current_user.resource_id).paginate(:page => params[:page])
      #end
      #
      #if params[:id].to_i != 0
      #  @orgs = Fdn::Organization.find(params[:id]).with_hierarchy.children#.arrange
      #else
      #  @orgs = [Fdn::Organization.find(session[:org_id]).with_hierarchy]
      #end

      @org = Fdn::Organization.find @org_id
      @search = Fdn::Role.search(params[:q])
      @roles = @search.result.where(:organization_id=> @org_id).available.paginate(:page => params[:page])

      respond_to do |format|
        format.html
        format.xml
      end
    end

    def detail_refresh
      @org_id = !params[:org_id].blank? ? params[:org_id] : session[:org_id]
      @org = Fdn::Organization.find @org_id
      @search = Fdn::Role.search(params[:q])
      @roles = @search.result.where(:organization_id=> @org_id).available.paginate(:page => params[:page])
    end

    def org_tree
      @org_id = params[:org_id]
      if !params[:org_id].blank?# && params[:id] != '#'
        if params[:org_id] == '1'
          @orgs = Fdn::Organization.find(params[:org_id]).with_hierarchy.children
        else
          @orgs = Fdn::Organization.find(params[:org_id]).with_hierarchy.children
        end
        @other_orgs = []
      else
        @orgs = [Fdn::Organization.find(session[:org_id]).with_hierarchy]
        @show_orgs = Fdn::Organization.first.with_hierarchy.all_descendants
        @show_orgs << Fdn::Organization.first
        @other_orgs = Fdn::Organization.where("id not in (?)",@show_orgs.collect{|o|o.id})
      end
    end

    def kb_tree
      if params[:id].to_i != 0
        @orgs1 = Fdn::Organization.find(params[:id]).with_hierarchy(2).children
      else
        @orgs1 = [Fdn::Organization.find(session[:org_id]).with_hierarchy(2)]
      end
      respond_to do |format|
        format.xml
      end
    end
    def nb_tree
      if params[:id].to_i != 0
        @orgs2 = Fdn::Organization.find(params[:id]).with_hierarchy(3).children
      else
        @orgs2 = [Fdn::Organization.find(session[:org_id]).with_hierarchy(3)]
      end
      respond_to do |format|
        format.xml
      end
    end
    def ys_tree
      if params[:id].to_i != 0
        @orgs3 = Fdn::Organization.find(params[:id]).with_hierarchy(4).children
      else
        @orgs3 = [Fdn::Organization.find(session[:org_id]).with_hierarchy(4)]
      end
      respond_to do |format|
        format.xml
      end
    end

    def new
      @org_id = params[:org_id]||session[:org_id]
      @role = Fdn::Role.new(organization_id:params[:org_id])
    end

    def edit
      @role = Fdn::Role.find(params[:id])
    end

    def show
      @role = Fdn::Role.find(params[:id])
    end

    def create
      @role = Fdn::Role.new(fdn_role_params)
      if @role.save
        respond_to do |format|
          format.html { render :js => view_context.close_window_refresh_div_show_tips('parent.MAIN_LAYER_WINDOW',url_for(:controller => 'fdn/roles',:action => :detail_refresh),"'org_id': '#{@role.organization.id}'",'角色创建成功！')}
        end
        #redirect_to index_main_fdn_roles_url(:org_id => @role.organization_id)
        #redirect_to :action => "index"
      else
        #prepare_page
        render :action => "new"
      end
    end

    def update
      @role = Fdn::Role.find(params[:id])

      #保存权限
      if !params[:right_ids].nil?
        @role.rights.delete_all
        params["right_ids"].split('|').each do |right_id|
          if right_id.to_s[0] == 'r'
            right_id = right_id.delete 'r'
            right = Fdn::Right.find(right_id)
            @role.rights << right
          end
        end
        @role.save
        respond_to do |format|
          format.html { render :js => view_context.close_window_refresh_div_show_tips('parent.MAIN_LAYER_WINDOW',url_for(:controller => 'fdn/roles',:action => :detail_refresh),"'org_id': '#{@role.organization.id}'",'权限菜单分配成功！')}
        end
      end
      ##保存用户 && 保存基本信息
      if params[:right_ids].nil?
        if @role.update_attributes(fdn_role_params)
          respond_to do |format|
            format.html { render :js => view_context.close_window_refresh_div_show_tips('parent.MAIN_LAYER_WINDOW',url_for(:controller => 'fdn/roles',:action => :detail_refresh),"'org_id': '#{@role.organization.id}'",'角色修改成功！')}
          end
        end
      end
    end

    def refresh

    end

    def user
      @role = Fdn::Role.find(params[:id])
      @users = Fdn::User.available.by_org_ids([params[:organization_id]])#.order('seq')
      render :layout=>'form'
    end

    def right
      @role = Fdn::Role.find(params[:id])
      #@right_classes = Fdn::Right.all(:select => '')
      #@right_acts = Fdn::Right.all#(:select => 'distinct code')
      #@rights = Fdn::Right.all
      @right_ids = @role.rights.collect { |right| right.id }#.join('|')
      @organization_id = params[:organization_id]
      render :layout=>'form'
    end

    def treeload
      @role = Fdn::Role.find(params[:role_id])
      @right_ids = @role.rights.collect { |right| right.id }
      @org = Fdn::Organization.find params[:organization_id]
      if @org.resource_type == 'Fdn::Dept'
        @menus = Fdn::Menu.roots[0].descendants.active
      else
        @menus = Fdn::Menu.roots[0].descendants.active#.not_in(Fdn::Menu::ENT_NENUS)
      end
      @menus_trees = @menus.map { |m| {:id => m.id, :parent => (m.parent_id== 1? "#":m.parent_id), :text => m.name, :child_c => m.children_count } }
      @rights = Fdn::Right.in_menu.menu_id_in(@menus.collect {|m| m.id}).map { |m| {:id => 'r'+m.id.to_s, :parent => m.menu_id, :text => m.rigt_desc, :child_c => 0,:state => {selected: @right_ids.index(m.id)? true : false}} }
      @trees = @menus_trees + @rights
      respond_to do |format|
        format.json { render :json => @trees }
      end

    end

    def destroy
      @role = Fdn::Role.find(params[:id])
      @org_id = @role.organization.id
      @role.destroy
      #redirect_to :back
      #respond_to do |format|
      #  format.html { render :js => "<script>alert(1111111111111111);</script>"}
      #  #format.html { render :js => view_context.delete_refresh_div_show_tips(url_for(:controller => 'fdn/roles',:action => :detail_refresh),"'org_id': '#{@org_id}'",'角色删除成功！')}
      #end
      redirect_to :action => "index"
    end

    def destroy_record
      @role = Fdn::Role.find(params[:id])
      @org_id = @role.organization.id
      @role.destroy
      @org = Fdn::Organization.find @org_id
      @roles = Fdn::Role.where(:organization_id=> @org_id).available.paginate(:page => params[:page])
    end

    def prepare_page
      @users = Fdn::User.available.order('seq')
      @rights = Fdn::Right.all(:select => 'distinct type_code').collect { |right| [right.right_type.value, right.type_code] }
      @rights_all = Fdn::Right.all(:include => :right_inst)
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_fdn_role
      @role = Fdn::Role.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def fdn_role_params
      params.require(:fdn_role).permit! if params[:fdn_role]
    end
  end
end