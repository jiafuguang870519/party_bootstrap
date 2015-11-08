#coding: utf-8
class Fdn::UsersController < ApplicationController
  before_action :set_fdn_user, only: [:show, :edit, :update, :destroy]

  # GET /fdn/users
  # GET /fdn/users.json
  def index
    @org_id = !params[:org_id].blank? ? params[:org_id] : session[:org_id]
    @org = Fdn::Organization.find @org_id
    @search = Fdn::User.search(params[:q])
    @users = @search.result.by_org_id(@org_id).paginate(:page => params[:page])
  end

  def detail_refresh
    @org_id = !params[:org_id].blank? ? params[:org_id] : session[:org_id]
    @org = Fdn::Organization.find @org_id
    @search = Fdn::User.search(params[:q])
    @users = @search.result.by_org_id(@org_id).paginate(:page => params[:page])
  end

  # GET /fdn/users/1
  # GET /fdn/users/1.json
  def show
  end

  # GET /fdn/users/new
  def new
    @org_id = params[:org_id]||session[:org_id]
    @fdn_user = Fdn::User.new()
    @fdn_user.build_user_information
    @fdn_user.resource = Fdn::Organization.find(params[:org_id])
  end

  # GET /fdn/users/1/edit
  def edit
  end

  # POST /fdn/users
  # POST /fdn/users.json
  def create
    @fdn_user = Fdn::User.new(fdn_user_params)
    @fdn_user.resource = Fdn::Organization.find(params[:org_id])

    respond_to do |format|
      if @fdn_user.save
        format.html { render :js => view_context.close_window_refresh_div_show_tips('parent.MAIN_LAYER_WINDOW',url_for(:controller => 'fdn/users',:action => :detail_refresh),"'org_id': '#{@fdn_user.resource_id}'",'用户创建成功！')}
        #format.html { render :js => view_context.close_window_show_tips('parent.MAIN_LAYER_WINDOW','用户创建成功！') }
        format.json { render :show, status: :created, location: @fdn_user }
      else
        format.html { render :new }
        format.json { render json: @fdn_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /fdn/users/1
  # PATCH/PUT /fdn/users/1.json
  def update
    respond_to do |format|
      if @fdn_user.update(fdn_user_params)
        format.html { render :js => view_context.close_window_refresh_div_show_tips('parent.MAIN_LAYER_WINDOW',url_for(:controller => 'fdn/users',:action => :detail_refresh),"'org_id': '#{@fdn_user.resource_id}'",'用户修改成功！')}
        #format.html { render :js => view_context.close_window_show_tips('parent.MAIN_LAYER_WINDOW','用户修改成功！') }
        format.json { render :show, status: :ok, location: @fdn_user }
      else
        format.html { render :edit }
        format.json { render json: @fdn_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fdn/users/1
  # DELETE /fdn/users/1.json
  def destroy
    @fdn_user.destroy
    respond_to do |format|
      format.html { redirect_to fdn_users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def stop
    @users = Fdn::User.find_by_id params[:id]
    @users.status = params[:act]
    @users.save
    redirect_to detail_refresh_fdn_users_url(:org_id => @users.resource_id)
    #respond_to do |format|
    #  format.html { render :js => view_context.close_window_refresh_div_show_tips('parent.MAIN_LAYER_WINDOW',url_for(:controller => 'fdn/users',:action => :detail_refresh),"'org_id': '#{@users.resource_id}'",'用户修改成功！')}
    #end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_fdn_user
      @fdn_user = Fdn::User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def fdn_user_params
      params.require(:fdn_user).permit! if params[:fdn_user]
    end
end
