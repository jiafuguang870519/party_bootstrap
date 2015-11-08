class Fdn::PartyOrgsController < ApplicationController
  before_action :set_fdn_party_org, only: [:show, :edit, :update, :destroy]

  # GET /fdn/party_orgs
  # GET /fdn/party_orgs.json
  def index
    @fdn_party_orgs = Fdn::PartyOrg.all
  end

  # GET /fdn/party_orgs/1
  # GET /fdn/party_orgs/1.json
  def show
  end

  # GET /fdn/party_orgs/new
  def new
    @fdn_party_org = Fdn::PartyOrg.new
  end

  # GET /fdn/party_orgs/1/edit
  def edit
  end

  # POST /fdn/party_orgs
  # POST /fdn/party_orgs.json
  def create
    @fdn_party_org = Fdn::PartyOrg.new(fdn_party_org_params)

    respond_to do |format|
      if @fdn_party_org.save
        format.html { redirect_to @fdn_party_org, notice: 'Party org was successfully created.' }
        format.json { render :show, status: :created, location: @fdn_party_org }
      else
        format.html { render :new }
        format.json { render json: @fdn_party_org.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /fdn/party_orgs/1
  # PATCH/PUT /fdn/party_orgs/1.json
  def update
    respond_to do |format|
      if @fdn_party_org.update(fdn_party_org_params)
        format.html { redirect_to @fdn_party_org, notice: 'Party org was successfully updated.' }
        format.json { render :show, status: :ok, location: @fdn_party_org }
      else
        format.html { render :edit }
        format.json { render json: @fdn_party_org.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fdn/party_orgs/1
  # DELETE /fdn/party_orgs/1.json
  def destroy
    @fdn_party_org.destroy
    respond_to do |format|
      format.html { redirect_to fdn_party_orgs_url, notice: 'Party org was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def import

    if params[:file].nil?
      puts "1111111111111111111111111111111111111111111"
    end

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_fdn_party_org
      @fdn_party_org = Fdn::PartyOrg.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def fdn_party_org_params
      params.require(:fdn_party_org).permit(:name, :parent_name, :setting_date, :party_members, :pre_party_members, :activist_party_members)
    end
end
