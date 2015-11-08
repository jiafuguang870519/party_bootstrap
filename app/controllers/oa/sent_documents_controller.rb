#coding: utf-8
class Oa::SentDocumentsController < ApplicationController
  before_action :set_oa_sent_document, only: [:show, :edit, :update, :destroy]
  #skip_before_filter :require_user
  # GET /oa/sent_documents
  # GET /oa/sent_documents.json
  def index
    @docs = Oa::SentDocument.all#.paginate(:page => params[:page], :order => 'created_at desc')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @docs }
    end
  end

  # GET /oa/sent_documents/1
  # GET /oa/sent_documents/1.json
  def show
    @oa_sent_document = Oa::SentDocument.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @oa_sent_document }
    end
  end

  # GET /oa/sent_documents/new
  # GET /oa/sent_documents/new.json
  def new
    if !params[:resource_type].blank?&&params[:resource_type] == "Hr::JobRevision"
      @hr_job_revision = Hr::JobRevision.find(params[:resource_id])
      content = "<center><h3>" + "关于" + @hr_job_revision.person.full_name + "同志职务任免的通知" + "</h3></center><br/>" + Hr::JobRevision.mix_job_revision_content(@hr_job_revision)
      @oa_sent_document = Oa::SentDocument.new(:title=>("关于" + @hr_job_revision.person.full_name + "同志职务任免的通知"),:content=>content)
    elsif params[:sam_report_summary]
      puts params[:file]
      @org = Fdn::Organization.find(params[:ent_id])
      @sam_report_summary = Sam::ReportSummary.find(params[:sam_report_summary])
      @oa_sent_document = Oa::SentDocument.new(:title=>(@org.name + @sam_report_summary.check_date.year.to_s + '年' + @sam_report_summary.check_type ),:organization_id=>params[:ent_id])
      @files = Fdn::FileResource.find(params[:file])
    else
      @oa_sent_document = Oa::SentDocument.new
      #@oa_sent_document.files.build
      #@oa_sent_document.doc_type_code = Oa::Lookups::DocType.select_y.first[1]
      #@oa_recv_document = Oa::RecvDocument.find_by_id(params[:recv_document_id])
    end
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @oa_sent_document }
    end
  end

  # GET /oa/sent_documents/1/edit
  def edit
    @oa_sent_document = Oa::SentDocument.find(params[:id])
    #@oa_sent_document.process.wi_by_user(current_user.username)
  end

  # POST /oa/sent_documents
  # POST /oa/sent_documents.json
  def create
    @oa_sent_document = Oa::SentDocument.new(oa_sent_document_params)
    #@recv_document = Oa::RecvDocument.find_by_id(params[:recv_document_id])
    respond_to do |format|
      if @oa_sent_document.save
        format.html { render :js => view_context.close_window_show_tips('parent.MAIN_LAYER_WINDOW','发文创建成功！') }
        format.json { render :show, status: :created, location: @oa_sent_document }
      else
        format.html { render :new }
        format.json { render json: @oa_sent_document.errors, status: :unprocessable_entity }
      end
    end
    #respond_to do |format|
    #  if @oa_sent_document.save_with_recv(@recv_document) && @oa_sent_document.launch((@recv_document.process.id if @recv_document))
    #    format.html { redirect_to edit_oa_sent_document_url(@oa_sent_document), notice: '拟文创建成功' }
    #    format.json { render json: @oa_sent_document, status: :created, location: @oa_sent_document }
    #  else
    #    format.html { render action: "new" }
    #    format.json { render json: @oa_sent_document.errors, status: :unprocessable_entity }
    #  end
    #end
  end

  # PUT /oa/sent_documents/1
  # PUT /oa/sent_documents/1.json
  def update
    @oa_sent_document = Oa::SentDocument.find(params[:id])
    respond_to do |format|
      if @oa_sent_document.update(oa_sent_document_params)
        format.html { render :js => view_context.close_window_show_tips('parent.MAIN_LAYER_WINDOW','发文更新成功！')  }
        format.json { render :show, status: :ok, location: @oa_sent_document }
      else
        format.html { render :edit }
        format.json { render json: @oa_sent_document.errors, status: :unprocessable_entity }
      end
    end
    #@oa_sent_document.process.wi_by_user(current_user.username)
    #respond_to do |format|
    #  if params[:save]
    #    if  @oa_sent_document.update_attributes(params[:oa_sent_document])
    #      format.html { redirect_to :back, :notice => I18n.t('m.save_success') }
    #    else
    #      format.html { render action: "edit" }
    #    end
    #  else
    #    if update_result(@oa_sent_document, params[:oa_sent_document], wf_params)
    #      format.html { redirect_to oa_sent_documents_url, notice: I18n.t('m.save_success') }
    #      format.json { head :ok }
    #    else
    #      format.html { render action: "edit" }
    #      format.json { render json: @oa_sent_document.errors, status: :unprocessable_entity }
    #    end
    #  end
    #
    #end
  end

  # DELETE /oa/sent_documents/1
  # DELETE /oa/sent_documents/1.json
  def destroy
    @oa_sent_document = Oa::SentDocument.find(params[:id])
    @oa_sent_document.destroy

    respond_to do |format|
      format.html { redirect_to oa_sent_documents_url }
      format.json { head :ok }
    end
  end

  def add_file
    @oa_sent_document = params[:id] ? Oa::SentDocument.find(params[:id]) : Oa::SentDocument.new
    @the_file = @oa_sent_document.file_resources.build
    @index = params[:index].to_i
    respond_to do |format|
      format.js
    end
  end

  def del_file
    @file_id = params[:id]
    if params[:if_resource]=='yes'
      Fdn::FileResource.delete(params[:id])
    end
    respond_to do |format|
      format.html
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_oa_sent_document
      @oa_sent_document = Oa::SentDocument.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def oa_sent_document_params
      params.require(:oa_sent_document).permit! if params[:oa_sent_document]
    end

end
