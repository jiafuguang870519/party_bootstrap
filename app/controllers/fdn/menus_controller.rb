#coding: utf-8
class Fdn::MenusController < ApplicationController
  before_action :set_fdn_menu, only: [:show, :edit, :update, :destroy]


  # GET /fdn/menus
  # GET /fdn/menus.json
  def index
    #@fdn_menus = Fdn::Menu.all
    @fdn_menu = Fdn::Menu.top_level.first
  end

  # GET /fdn/menus/1
  # GET /fdn/menus/1.json
  def show
  end

  # GET /fdn/menus/new
  def new
    @fdn_menu = Fdn::Menu.new
  end

  def tree
    #菜单父子关系
    @fdn_menus = Fdn::Menu.roots[0].descendants.arrange
  end

  # GET /fdn/menus/1/edit
  def edit
  end

  # POST /fdn/menus
  # POST /fdn/menus.json
  def create
    @fdn_menu = Fdn::Menu.new(fdn_menu_params)

    respond_to do |format|
      if @fdn_menu.save
        format.html { render :js => view_context.close_window_show_tips('parent.MAIN_LAYER_WINDOW','功能菜单创建成功！') }
        format.json { render :show, status: :created, location: @fdn_menu }
      else
        format.html { render :new }
        format.json { render json: @fdn_menu.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /fdn/menus/1
  # PATCH/PUT /fdn/menus/1.json
  def update
    respond_to do |format|
      if @fdn_menu.update(fdn_menu_params)
        format.html { render :js => view_context.close_window_show_tips('parent.MAIN_LAYER_WINDOW','功能菜单更新成功！')  }
        format.json { render :show, status: :ok, location: @fdn_menu }
      else
        format.html { render :edit }
        format.json { render json: @fdn_menu.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fdn/menus/1
  # DELETE /fdn/menus/1.json
  def destroy
    @fdn_menu.destroy
    respond_to do |format|
      format.html { redirect_to fdn_menus_url, notice: 'Menu was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def detail_refresh
    @fdn_menu = Fdn::Menu.find(params[:id])
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_fdn_menu
      @fdn_menu = Fdn::Menu.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def fdn_menu_params
      params.require(:fdn_menu).permit! if params[:fdn_menu]
    end
end
