#coding: utf-8
class Fdn::LoggersController < ApplicationController
  # GET /fdn/loggers
  # GET /fdn/loggers.json
  def index
    ##导入代码
    #require 'spreadsheet'
    #Spreadsheet.client_encoding = "UTF-8"
    #path = Rails.root.join('public', 'abc.xls')
    #book = Spreadsheet.open path
    #sheet = book.worksheet(0)
    #arr = []
    #i = 0
    ##把第一行字段名和序号存到Hash中
    #data = Hash.new
    #row = sheet.row(0)
    #row.size.times do
    #  data[i] = row[i]
    #  i = i +1
    #end
    ##@parent_org：挂在哪一个区下
    #sheet.each 1 do |row|
    #  @parent_org = Fdn::Organization.find row[0]
    #  #判断组织机构代码
    #  code = row[data.key('ent_code')].blank? ? (!row[data.key('nat_tax_code')].blank? ? row[data.key('nat_tax_code')][-9,9] : '') : row[data.key('ent_code')]
    #  if !code.blank?
    #    if Fdn::Organization.where("code = ?",code).size != 0
    #      @org = Fdn::Organization.where("code = ?",code).first
    #      @ent = @org.resource
    #      #同步数据
    #      data.each {|key, value| @ent.send("#{value}=", row[key]) if key != 0 }
    #      @ent.save
    #      @org.name = row[data.key('ent_name')]
    #      @org.short_name = row[data.key('ent_name')]
    #      @org.save
    #      #更新history表
    #      @ent.update_history
    #    else
    #      @ent = Fdn::Enterprise.new
    #      @org = @ent.build_organization
    #      #同步数据
    #      data.each {|key, value| @ent.send("#{value}=", row[key]) if key != 0  }
    #      @ent.ent_code = code
    #      @ent.start_time = "2011-12-31 23:59:59"
    #      @org.name = row[data.key('ent_name')]
    #      @org.short_name = row[data.key('ent_name')]
    #      @org.code = code
    #      @ent.save
    #      #增加到企业树结构
    #      @parent_org.with_hierarchy.add_child(@org.id, nil, nil)
    #      #创建history表
    #      @ent_his = Fdn::EnterpriseHistory.new
    #      @ent_his.start_time = "2011-12-31 23:59:59"
    #      @ent_his.copy_data(@ent)
    #    end
    #  else
    #    #输出有问题的企业名
    #    arr << row[data.key('ent_name')].to_s
    #  end
    #end
    #p '################'
    #p arr
    params[:q] = params[:q] ? params[:q] : {}
    date_to_end_time(params[:q], [:act_at_lteq])
    @search = Fdn::Logger.search(params[:q])
    @fdn_loggers = @search.result.more_search(params[:q], params[:page]||1)
  end

  # GET /fdn/loggers/1
  # GET /fdn/loggers/1.json
  def show
    @fdn_logger = Fdn::Logger.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @fdn_logger }
    end
  end

  # GET /fdn/loggers/new
  # GET /fdn/loggers/new.json
  def new
    @fdn_logger = Fdn::Logger.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @fdn_logger }
    end
  end

  # GET /fdn/loggers/1/edit
  def edit
    @fdn_logger = Fdn::Logger.find(params[:id])
  end

  # POST /fdn/loggers
  # POST /fdn/loggers.json
  def create
    @fdn_logger = Fdn::Logger.new(params[:fdn_logger])

    respond_to do |format|
      if @fdn_logger.save
        format.html { redirect_to @fdn_logger, notice: 'Logger was successfully created.' }
        format.json { render json: @fdn_logger, status: :created, location: @fdn_logger }
      else
        format.html { render action: "new" }
        format.json { render json: @fdn_logger.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /fdn/loggers/1
  # PUT /fdn/loggers/1.json
  def update
    @fdn_logger = Fdn::Logger.find(params[:id])

    respond_to do |format|
      if @fdn_logger.update_attributes(params[:fdn_logger])
        format.html { redirect_to @fdn_logger, notice: 'Logger was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @fdn_logger.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fdn/loggers/1
  # DELETE /fdn/loggers/1.json
  def destroy
    @fdn_logger = Fdn::Logger.find(params[:id])
    @fdn_logger.destroy

    respond_to do |format|
      format.html { redirect_to fdn_loggers_url }
      format.json { head :no_content }
    end
  end

  def show_info
    @user = Fdn::User.find params[:id]
    render :layout=>'form'
  end
end
