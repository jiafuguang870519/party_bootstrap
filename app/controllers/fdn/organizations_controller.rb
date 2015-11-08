#coding=utf-8
class Fdn::OrganizationsController < ApplicationController
  protect_from_forgery except: :rjs_all_of

  def edit_org
    @fdn_organizations = Fdn::Organization.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml
      format.json { render :json => @fdn_organizations }
    end
  end

  def tree_index
    @org_id = params[:org_id]
    @hierarchy_id = params[:hierarchy_id].blank? ? 1 : params[:hierarchy_id]
    @org_hierarchy = Fdn::OrgHierarchy.find @hierarchy_id
    @eff_time =  params[:eff_time].blank? ? Time.now : params[:eff_time].to_time
    @tab_idx = params[:tab_idx] || 0
    #@gov = Fdn::Organization.search_dept.other
    @without_ent_id = Fdn::Organization.where("resource_type = 'Fdn::Enterprise'").pluck(:id)
    node = params[:nodeid]
    @nodeid = params[:nodeid]
    #@search = Fdn::Organization.ransack(params[:q])
    if node
      parent_org = Fdn::Organization.find(node).with_hierarchy(@hierarchy_id,@eff_time)
      @fdn_organizations = Fdn::Organization.s_children(@hierarchy_id, @eff_time, parent_org.id)
      #@fdn_organizations = parent_org.children
    else
      if !params[:org_id].blank?
        org = Fdn::Organization.find(params[:org_id]).with_hierarchy(@hierarchy_id,@eff_time)
      else
        org = Fdn::Organization.find(session[:org_id]).with_hierarchy(@hierarchy_id,@eff_time)
      end
      @fdn_organizations = []
      #@fdn_organizations = [org]
      @fdn_organizations << org
      #@fdn_organizations << org
    end
    @show_orgs = Fdn::Organization.first.with_hierarchy(@hierarchy_id,@eff_time).all_descendants
    @show_orgs << Fdn::Organization.first
    @other_orgs = Fdn::Organization.where("id not in (?)",@show_orgs.collect{|o|o.id})

    respond_to do |format|
      format.html {render :layout => 'form'}# index.html.erb
      format.xml
      format.json { render :json => @fdn_organizations }
    end
  end

  def ent_index
    params[:q] = params[:q] ? params[:q] : {}
    @search = Fdn::Organization.ransack(params[:q])
    @organizations = @search.result.where("resource_type = 'Fdn::Enterprise'").paginate(:page => params[:page])
    #@organizations = Fdn::Organization.where("resource_type = 'Fdn::Enterprise'").paginate(:page => params[:page])
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @organizations }
    end
  end

  def index
    @tab_idx = params[:tab_idx] || 0
    @hierarchies = Fdn::OrgHierarchy.all
    #@org_id = params[:org_id]
    ##@gov = Fdn::Organization.search_dept.other
    #@with_out_ent_id = Fdn::Organization.where("resource_type != 'Fdn::Enterprise'").pluck(:id)
    #node = params[:nodeid]
    ##@search = Fdn::Organization.ransack(params[:q])
    #if node
    #  parent_org = Fdn::Organization.find(node).with_hierarchy
    #  @fdn_organizations = Fdn::Organization.s_children(parent_org.hierarchy_id, parent_org.eff_time, parent_org.id)
    #  #@fdn_organizations = parent_org.children
    #else
    #  if !params[:org_id].blank?
    #    org = Fdn::Organization.find(params[:org_id]).with_hierarchy
    #  else
    #    org = Fdn::Organization.find(session[:org_id]).with_hierarchy
    #  end
    #  @fdn_organizations = []
    #  #@fdn_organizations = [org]
    #  @fdn_organizations << org
    #  #@fdn_organizations << org
    #end

    respond_to do |format|
      format.html # index.html.erb
      format.xml
      format.json { render :json => @fdn_organizations }
    end
  end

  def show_history
    #@org_id = params[:org_id]
    @org = Fdn::Organization.find params[:id]
    @org_his = @org.org_his.order("end_time DESC")
    #@org_his = Fdn::OrganizationHistory.where(:org_id => @org_id).order("end_time DESC")
  end

  def add_or_delete
    @org = Fdn::Organization.find params[:id]
    @org.change_status
    respond_to do |format|
      format.html { redirect_to fdn_organizations_url(org_id: @org.id) }
      format.json { head :ok }
    end
  end

  def history_show
    @history = Fdn::OrganizationHistory.find params[:id]
  end

  # GET /fdn/organizations/1
  # GET /fdn/organizations/1.json
  def show
    @tab_idx = params[:tab_idx] || 0
    @fdn_organization = Fdn::Organization.find(params[:id])
    #@pprs = Prs::PropertyRight.by_ent_id(@fdn_organization.resource_id)
    #if @fdn_organization.org_type_code == 'ENT'
    #  @investors = Fdn::EntInvestor.where('org_id = ?', @fdn_organization.id).order("percentage DESC")
    #end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @fdn_organization }
    end
  end

  def ent_show
    @org = Fdn::Organization.find(params[:id])
    @send_docs = Oa::SentDocument.q(current_user.id, nil, 100, {'org_id' => params[:id]})
    @recv_docs = Oa::RecvDocument.q(current_user.id, nil, 100, {'org_id' => params[:id]})
  end

  def ent_db
    org = Fdn::Organization.find(session[:org_id]).with_hierarchy
    @org_root_elements = []
    root = org.root
    #一级企业
    root.level = 1
    @org_root_elements << root
    #二级企业
    root.children.each do |ent_child|
      ent_child.level = 2
      @org_root_elements << ent_child
    end
  end

  def search_db
    @ents = Fdn::Organization.select_ent
    unless params[:ent_name].blank?
      @ents = @ents.like_name(params[:ent_name])
    end
    unless params[:level_code].blank?
      @ents = @ents.where("fdn_enterprises.ent_level_code = ?", params[:level_code])
    end
  end

  def ent_ajax
    @org = Fdn::Organization.find(params[:org_id]).with_hierarchy
    @org_elements = []
    @act = params[:act]
    #显示子企业
    if @act == 'add'
      @level = params[:level].to_i
      @org.children.each do |ent_child|
        ent_child.level = (@level + 1)
        @org_elements << ent_child
      end
      #隐藏子企业
    else
      @org_elements = @org.descendants.values.flatten.map { |o| o.id }
    end

    respond_to do |format|
      format.js
    end
  end

  # GET /fdn/organizations/new
  # GET /fdn/organizations/new.json
  def new
    @parent_id = params[:parent_id]
    @type = params[:type]
    if @type == 'ENT'
      #创建企业
      @obj = Fdn::Enterprise.new
    else
      #创建区域
      @obj = Fdn::Dept.new(:type_code => @type)
    end
    @obj.build_organization
    #@enterprise = @fdn_organization.enterprise.new
    respond_to do |format|
      format.html # new.html.erb
      format.json
    end
  end

  # GET /fdn/organizations/1/edit
  def edit
    @fdn_organization = Fdn::Organization.find(params[:id])
    @obj = @fdn_organization.resource
    @type = (@fdn_organization.resource_type == 'Fdn::Dept' ? 'DEPT' : 'ENT')
    #@status_code = Fdn::Lookups::PprStatus.where("code <= ? and code > ? ", '5', '1')
    #@obj.get_out_in_value if @fdn_organization.resource_type == "Fdn::Enterprise"
  end

  # POST /fdn/organizations
  # POST /fdn/organizations.json
  def create
    if params[:oper] == "edit"
      @org = Fdn::Organization.find params[:id]
      #@org.status = (params[:show_status] == '已启用' ? 'Y' : 'N')
      @org.change_status
      if @org.save
        redirect_to :action => :index
      else
        render action: 'edit'
      end
    else
      if params[:type] == 'ENT'
        #if params[:fdn_enterprise][:file_resources_attributes]
        #  params[:fdn_enterprise][:file_resources_attributes].each do |p|
        #    if p[1][:file_class_id].blank? && !p[1][:other_class].blank?
        #      @ex_oth = Fdn::FileClass.where("class_name = ?", p[1][:other_class])
        #      if @ex_oth.size == 0
        #        @oth_class = Fdn::FileClass.new(:class_name => p[1][:other_class], :resource_type => 'Fdn::Enterprise')
        #        @oth_class.save
        #        p[1][:file_class_id] = @oth_class.id
        #      else
        #        p[1][:file_class_id] = @ex_oth.first.id
        #      end
        #    end
        #  end
        #end
        @obj = Fdn::Enterprise.new(fdn_enterprise_params)
        @obj.organization.code = @obj.ent_code
        #@obj.ent_name = @obj.organization.name
        #if params[:fdn_enterprise][:qylb]
        #  @obj.qylb = params[:fdn_enterprise][:qylb].join(',')
        #end
      else
        @obj = Fdn::Dept.new(fdn_dept_params)
      end
      #@obj.start_date = Time.now.to_date
      respond_to do |format|
        if @obj.save
          @time = Time.now
          #产权、快报、预算、年报、决算
          Fdn::Organization::HIERARCHY_TREE_PARAMS.each do |arr|
            if !params["#{arr[1]}"].blank?
              @parent_org = Fdn::Organization.find(params["#{arr[1]}"])
              @parent_org.with_hierarchy(arr[0],@time).add_child(@obj.organization.id, nil, nil)
              #在有组织树变动的时候记录变动时间点
              Fdn::OrgTreeChange.create(hierarchy_id:arr[0],change_time:@time)
            end
          end
          #创建历史记录
          if params[:type] == 'ENT'
            @ent_his = Fdn::EnterpriseHistory.new
            @ent_his.start_time = Time.now
            @ent_his.copy_data(@obj)
          else
            @dept_his = Fdn::DeptHistory.new
            @dept_his.start_time = Time.now
            @dept_his.copy_data(@obj)
          end
          format.html { render :js => view_context.close_window_show_tips('parent.MAIN_LAYER_WINDOW','企业创建成功！') }
        else
          render :action => "new"
        end
      end
    end
  end

  # PUT /fdn/organizations/1
  # PUT /fdn/organizations/1.json
  def update
    if params[:type] == 'ENT'
      #if params[:fdn_enterprise][:file_resources_attributes]
      #  params[:fdn_enterprise][:file_resources_attributes].each do |p|
      #    if p[1][:file_class_id].blank? && !p[1][:other_class].blank?
      #      @ex_oth = Fdn::FileClass.where("class_name = ?", p[1][:other_class])
      #      if @ex_oth.size == 0
      #        @oth_class = Fdn::FileClass.new(:class_name => p[1][:other_class], :resource_type => 'Fdn::Enterprise')
      #        @oth_class.save
      #        p[1][:file_class_id] = @oth_class.id
      #      else
      #        p[1][:file_class_id] = @ex_oth.first.id
      #      end
      #    end
      #  end
      #end
      @obj = Fdn::Enterprise.find(params[:id])
      @obj.attributes=(fdn_enterprise_params)
      #@obj.ent_name = @obj.organization.name
      #if params[:fdn_enterprise][:qylb]
      #  @obj.qylb = params[:fdn_enterprise][:qylb].join(',')
      #end
    else
      @obj = Fdn::Dept.find(params[:id])
      @obj.attributes=(fdn_dept_params)
    end
    respond_to do |format|
      if @obj.save
        @org = @obj.organization
        @time = Time.now
        #产权、快报、预算、年报、决算
        Fdn::Organization::HIERARCHY_TREE_PARAMS.each do |arr|
          if @org.with_hierarchy(arr[0],@time).parent
            if !params["#{arr[1]}"].blank? && (@org.with_hierarchy(arr[0],@time).parent.id != params["#{arr[1]}"].to_i)
              @parent_org = Fdn::Organization.find(params["#{arr[1]}"])
              @org.with_hierarchy(arr[0],@time).change_parent(@parent_org.id, nil)
              Fdn::OrgTreeChange.create(hierarchy_id: @org.hierarchy_id,change_time: @time)
            elsif params["#{arr[1]}"].blank?
              @org.remove_self
              Fdn::OrgTreeChange.create(hierarchy_id: @org.hierarchy_id,change_time: @time)
            end
          else
            if !params["#{arr[1]}"].blank?
              @parent_org = Fdn::Organization.find(params["#{arr[1]}"])
              #@org.with_hierarchy.change_parent(@parent_org.id, nil)
              @parent_org.with_hierarchy(arr[0],@time).add_child(@obj.organization.id, nil, nil)
              #在有组织树变动的时候记录变动时间点
              Fdn::OrgTreeChange.create(hierarchy_id: arr[0],change_time: @time)
            end
          end
        end
        format.html { render :js => view_context.close_window_show_tips('parent.MAIN_LAYER_WINDOW','企业修改成功！') }
      else
        @fdn_organization = @obj.organization
        render :action => "edit"
      end
    end
  end

  # DELETE /fdn/organizations/1
  # DELETE /fdn/organizations/1.json
  def destroy
    @hierarchy_id = params[:hierarchy_id]
    @fdn_organization = Fdn::Organization.find(params[:id])
    #@fdn_organization.resource.destroy
    #不删除org，记录时间点后，在组织树上不显示
    time = Time.now
    @fdn_organization.with_hierarchy(@hierarchy_id,time)
    if @fdn_organization.children.blank?
      #如果是叶子节点，才可以change_time
      Fdn::OrgHieElement.need_disabled_by_child(@fdn_organization.hierarchy_id, @fdn_organization.id, @fdn_organization.eff_time).each do |ele|
        ele.disable(@fdn_organization.eff_time)
      end
      #记录树的变动
      Fdn::OrgTreeChange.create(hierarchy_id:@hierarchy_id,change_time:time)
    else

    end
    #重新启用
    #org_hie = Fdn::OrgHierarchy.find(@hierarchy_id)
    #time = Time.now
    #@parent_org = Fdn::Organization.find params[:cq_parent_id]
    #@fdn_organization = Fdn::Organization.find(params[:id])
    #@parent_org.with_hierarchy(@hierarchy_id,time).add_child(@fdn_organization.id, nil, nil)
    #Fdn::OrgTreeChange.create(hierarchy_id:@hierarchy_id,change_time:time)
    respond_to do |format|
      format.html { redirect_to fdn_organizations_url }
      format.json { head :ok }
    end
  end

  def select
    @iframe = params[:iframe]
    @display_field = params[:display_field]
    @value_field = params[:value_field]
    @org_groups = Fdn::OrgGroup.all
    @multi_select = (params[:multi_select].blank? || params[:multi_select] == '1') ? true : false
  end

  def select_org
    @iframe = params[:iframe]
    @display_field = params[:display_field]
    @value_field = params[:value_field]
    @org_groups = Fdn::OrgGroup.all
    @org_ids = params[:org_ids]
  end

  def ajax_group
    if params[:group_id].blank?
      render :nothing => true
    else
      @org_group = Fdn::OrgGroup.find(params[:group_id])
      @orgs = Fdn::Organization.where("id in (?)", @org_group.org_ids)
    end
  end

  def treeload
    @hie = Fdn::OrgHierarchy.find_by_code(params[:hie_code])
    @orgs = []
    if params[:class_id] == "0"
      @hie.root_element
      unless @hie.root_element.nil?
        @org = @hie.root
        @org.with_hierarchy(@hie.id)
        @orgs << @hie.root
      end
    else
      @parent_org = Fdn::Organization.find(params[:id])
      @parent_org.with_hierarchy(@hie.id)
      @orgs = @parent_org.children
    end

    respond_to do |format|
      format.xml
    end
  end

  def rjs_all_of
    #只显示自己和自己的父子
    #arr = Fdn::Organization.self_group(session[:org_id])
    #new_arr = arr.size > 0 ? arr : Fdn::Organization.all
    render :js => rjs_by_collection(Fdn::Organization.all, params[:columns], 'orgs')
    #render :js => rjs('Fdn::Organization', params[:columns], 'orgs')
  end

  def rjs_ent_of
    #arr = Fdn::Organization.self_group(session[:org_id])
    #a = arr.collect { |a| a.resource if !a.is_ent? }
    #new_arr = a.size > 0 ? a : Fdn::Organization.find_all_by_resource_type('Fdn::Enterprise')
    #render :js => rjs_by_collection(new_arr, params[:columns], 'ent_names')
    render :js => rjs_by_collection(Fdn::Organization.find_all_by_resource_type('Fdn::Enterprise'), params[:columns], 'ent_names')
  end

  def rjs_dept_of
    #arr = Fdn::Organization.self_group(session[:org_id])
    #a = arr.collect { |a| a.resource if a.is_ent? }
    #new_arr = a.size > 0 ? a : Fdn::Organization.find_all_by_resource_type('Fdn::Dept')
    #render :js => rjs_by_collection(new_arr, params[:columns], 'dept_names')
    render :js => rjs_by_collection(Fdn::Organization.find_all_by_resource_type('Fdn::Dept'), params[:columns], 'dept_names')
  end

  #点击新增一行，境内
  def add_investor
    if params[:id].to_i != 0
      @org = Fdn::Enterprise.find(params[:id])
      @investor = @org.investors.build
      @index = params[:index].to_i
    else
      @org = Fdn::Enterprise.new
      @investor = @org.investors.build
      @index = params[:index].to_i
    end
  end

  #境外
  def add_foreign_investor
    if params[:id] != "0"
      @org = Fdn::Enterprise.find(params[:id])
      @investor = @org.investors.build
      @index = params[:index].to_i
    else
      @org = Fdn::Enterprise.new
      @investor = @org.investors.build
      @index = params[:index].to_i
    end
  end

  #删除投资人
  def del_investor
    if params[:id]
      @investor = Fdn::EntInvestor.find(params[:id])
      @investor.destroy
    end

    respond_to do |format|
      format.js { render :js => "fdn.calcInvestmentPercentage();" }
    end
  end

  def search_org
    @node_id = params[:node_id]
    @hie_id = params[:hie_id]
    @action_name = params[:action_name]
    @notice_content = ""
  end

  #验证组织机构代码
  def check_code_of
    unless params[:orgcode].nil?
      orgcode = Fdn::OrgCode.new
      @orgcode_str = orgcode.get_org_code(params[:orgcode])
      logger.info @orgcode_str
    end
  end

  def show_graph_of
    if params[:parent] && params[:tid]
      org = Fdn::Organization.find(params[:tid].from(1)).with_hierarchy
      if (parent = org.parent) && org.id != session[:org_id].to_i
        @org_json = parent.to_mx_json_tree
      else
        @org_json = org.to_mx_json_tree
      end
    elsif params[:root]
      @org_json = Fdn::Organization.find(session[:org_id]).to_mx_json_tree
    elsif params[:cid]
      @org_json = Fdn::Organization.find(params[:cid].from(1)).to_mx_json_tree
    else
      @org_json = Fdn::Organization.find(session[:org_id]).to_mx_json_tree
    end
  end

  def change_main_inv_org_of
    @ent = Fdn::Enterprise.build_from_main_inv_org(params[:org_id], params[:is_foreign])
  end

  private
  #初始化新页面
  def prepare_new_page(org_type, internal)
    case org_type
      when Fdn::Organization::ENTERPRISE_TYPE
        @fdn_org_resource = Fdn::Enterprise.new
        @fdn_organization = @fdn_org_resource.build_organization
        @obj_name = Fdn::Enterprise.name.underscore
      when Fdn::Organization::DEPT_TYPE
        @fdn_org_resource = Fdn::Dept.new
        @fdn_organization = @fdn_org_resource.build_organization
        @obj_name = Fdn::Dept.name.underscore
        @internal = internal
      when Fdn::Organization::PARTY_TYPE
        @fdn_org_resource = Fdn::PartyOrg.new
        @fdn_organization = @fdn_org_resource.build_organization
        @obj_name = Fdn::PartyOrg.name.underscore
    end
  end

  #初始化编辑页面
  def prepare_edit_page(fdn_organization)
    case fdn_organization.resource_type
      when Fdn::Organization::ENTERPRISE_TYPE
        @fdn_org_resource = fdn_organization.resource
        @obj_name = Fdn::Enterprise.name.underscore
      when Fdn::Organization::DEPT_TYPE
        @fdn_org_resource = fdn_organization.resource
        @internal = @fdn_org_resource.internal.to_s
        @obj_name = Fdn::Dept.name.underscore
      when Fdn::Organization::PARTY_TYPE
        @fdn_org_resource = fdn_organization.resource
        @obj_name = Fdn::PartyOrg.name.underscore
    end
  end

  private
  def fdn_enterprise_params
    params.require(:fdn_enterprise).permit! if params[:fdn_enterprise]
  end

  def fdn_dept_params
    params.require(:fdn_dept).permit! if params[:fdn_dept]
  end

end