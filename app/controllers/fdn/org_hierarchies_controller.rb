#coding: utf-8
class Fdn::OrgHierarchiesController < ApplicationController
  before_action :set_fdn_org_hierarchy, only: [:show, :edit, :update, :destroy]
  # GET /fdn/org_hierarchies
  # GET /fdn/org_hierarchies.json
  def index
    @fdn_org_hierarchies = Fdn::OrgHierarchy.paginate(:page => params[:page]).order("created_by DESC")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @fdn_org_hierarchies }
    end
  end

  # GET /fdn/org_hierarchies/1
  # GET /fdn/org_hierarchies/1.json
  def show_version
    @fdn_org_hierarchy = Fdn::OrgHierarchy.find(params[:id])
    @current_rel_id = params[:current_rel_id]
    @org_elements = @fdn_org_hierarchy.org_hie_elements
    @ver = params[:ver]||@fdn_org_hierarchy.org_hie_versions.first.ver
  end

  # GET /fdn/org_hierarchies/new
  # GET /fdn/org_hierarchies/new.json
  def new
    @fdn_org_hierarchy=Fdn::OrgHierarchy.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @fdn_org_hierarchy }
    end
  end

  # GET /fdn/org_hierarchies/1/edit   k6vxx
  def edit
    @fdn_org_hierarchy = Fdn::OrgHierarchy.find(params[:id])
    @current_rel_id = params[:current_rel_id]
    @org_elements = @fdn_org_hierarchy.org_hie_elements
  end

  def show
    @fdn_org_hierarchy = Fdn::OrgHierarchy.find(params[:id])
  end


  # POST /fdn/org_hierarchies
  # POST /fdn/org_hierarchies.json
  def create
    @fdn_org_hierarchy = Fdn::OrgHierarchy.new(fdn_org_hierarchy_params)

    respond_to do |format|
      if @fdn_org_hierarchy.save
        @time = Time.now
        @org = Fdn::Organization.find @fdn_org_hierarchy.org_id
        @fdn_org_hierarchy.org_hie_elements.create(FactoryGirl.attributes_for(:main_element, p: @org, r: @org, c: @org, d: 0))
        #在有组织树变动的时候记录变动时间点
        Fdn::OrgTreeChange.create(hierarchy_id:@fdn_org_hierarchy.id,change_time:@time)
        format.html { render :js => view_context.close_window_show_tips('parent.MAIN_LAYER_WINDOW','组织架构创建成功！') }
      else
        format.html { render action: "new" }
        format.json { render json: @fdn_org_hierarchy.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /fdn/org_hierarchies/1
  # PUT /fdn/org_hierarchies/1.json
  def update
    @fdn_org_hierarchy = Fdn::OrgHierarchy.find(params[:id])

    respond_to do |format|
      if @fdn_org_hierarchy.update_attributes(fdn_org_hierarchy_params)
        format.html { render :js => view_context.close_window_show_tips('parent.MAIN_LAYER_WINDOW','组织架构修改成功！') }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @fdn_org_hierarchy.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fdn/org_hierarchies/1
  # DELETE /fdn/org_hierarchies/1.json
  def destroy

  end


  def treeload
    @fdn_org_hierarchy = Fdn::OrgHierarchy.find(params[:hie_id])
    @hie_id = params[:hie_id]
    @org_elements = []
    if @fdn_org_hierarchy.root_element
      root = @fdn_org_hierarchy.root
      root.with_hierarchy(@fdn_org_hierarchy.id, (params[:ver].nil? ? @fdn_org_hierarchy.curr_ver.ver : params[:ver]))
      @org_elements << root
      @org_elements << root.descendants.values if root.descendants
      @org_elements = @org_elements.flatten
    end
    respond_to do |format|
      format.xml
    end
  end

  #创建节点
  def treeload_create
    begin
      if params[:node_id]=='root'
        @current_org = Fdn::Organization.find(params[:belongs_to_org_id])
        @hie = Fdn::OrgHierarchy.find(params[:hie_id])
        @current_org.with_hierarchy(@hie.id, @hie.curr_ver.ver)
        @current_org.add_as_root
      else
        @current_org = Fdn::Organization.find(params[:node_id])
        @hie = Fdn::OrgHierarchy.find(params[:hie_id])
        @current_org.with_hierarchy(@hie.id, @hie.curr_ver.ver)
        @current_org.add_child(params[:belongs_to_org_id], "add")
      end
      respond_to do |format|
        format.html { redirect_to :action=>'close_window', :id=>params[:hie_id], :current_rel_id=>params[:node_id] }
      end
    rescue Exception
      prepare_org_search(params[:node_id], 'treeload_create')
      render 'fdn/organizations/search_org'
    end
  end

  #删除节点
  def treeload_remove
    @succ = 0
    @current_org = Fdn::Organization.find(params[:node_id])
    @hie = Fdn::OrgHierarchy.find(params[:hie_id])
    @current_org.with_hierarchy(@hie.id, @hie.curr_ver.ver)
    if @current_org.remove_self
      @succ = 1
    end
    render :text => @succ
  end

  #移动节点
  def treeload_move_node
    @succ = 0
    @current_org = Fdn::Organization.find(params[:node_id])
    @hie = Fdn::OrgHierarchy.find(params[:hie_id])
    @current_org.with_hierarchy(@hie.id, @hie.curr_ver.ver)
    if @current_org.change_parent(params[:parent_id], params[:seq].to_i)
      @succ = 1
    end
    render :text => @succ
  end

  #编辑节点
  def treeload_rename
    begin
      @succ = 0
      @current_org = Fdn::Organization.find(params[:node_id])
      @hie = Fdn::OrgHierarchy.find(params[:hie_id])
      @current_org.with_hierarchy(@hie.id, @hie.curr_ver.ver)
      parent_id = @current_org.parent.id
      @current_org.replaced_by(params[:belongs_to_org_id])
      respond_to do |format|
        format.html { redirect_to :action=>'close_window', :id=>params[:hie_id], :current_rel_id=>parent_id }
      end
    rescue Exception
      prepare_org_search(params[:node_id], 'treeload_rename')
      render 'fdn/organizations/search_org'
    end
  end

#删除时关闭模态窗口
  def close_window
    @hie_id = params[:id]
    @current_rel_id = params[:current_rel_id]
  end

  def prepare_org_search(node_id, action_name)
    @node_id = node_id
    @hie_id = params[:hie_id]
    @action_name = action_name
    @notice_content = I18n.t('activerecord.errors.messages.org_exist')
  end

  private
    def set_fdn_org_hierarchy
      @fdn_org_hierarchy = Fdn::OrgHierarchy.find(params[:id])
    end

    def fdn_org_hierarchy_params
      params.require(:fdn_org_hierarchy).permit! if params[:fdn_org_hierarchy]
    end

end
