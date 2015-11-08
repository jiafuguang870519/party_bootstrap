class Fdn::EnterpriseHistory < ActiveRecord::Base
  ##attr_accessible :ent_time, :start_time
  ENT_COLUMNS = Fdn::EnterpriseDomain::SyncWithPpr::ENT_COLUMNS + %w(ppr_status_code start_date operate_status_code)

  INV_COLUMNS = Fdn::EnterpriseDomain::SyncWithPpr::INV_COLUMNS + %w(actual_amt actual_amt_foreign last_id)

  belongs_to :ent, :class_name=>'Fdn::Enterprise'
  has_many :investors, :class_name => 'Fdn::EntInvestorHistory', :foreign_key => 'ent_id'
  accepts_nested_attributes_for :investors, :allow_destroy => true, :reject_if => proc { |attrs| (attrs['amount'].blank? && attrs['foreign_currency'].blank?) }
  has_many :results, :class_name => 'Fdn::EntResultHistory', :foreign_key => 'ent_id'
  has_many :industries, :class_name => 'Fdn::EntIndHistory', :foreign_key => 'ent_id'#, :order => 'seq'
  has_many :fdn_ent_individuals, :class_name => 'Fdn::EntIndividualHistory', :foreign_key => "ent_id"
  accepts_nested_attributes_for :fdn_ent_individuals, :allow_destroy => true, :reject_if => proc { |attr| attr[:individual_name].blank? }

  scope :by_start_time, lambda { |start_time| where("fdn_enterprise_histories.end_time >= ?", start_time) }
  scope :by_end_time, lambda { |end_time| where("fdn_enterprise_histories.start_time <= ?", end_time) }
  scope :by_ent_id, lambda { |ent_id| where("fdn_enterprise_histories.ent_id = ?", ent_id) }

  scope :invested_at, proc {|org_id, time|
    includes(:investors).where('fdn_ent_investor_histories.org_id = ?
                                and ? between fdn_enterprise_histories.start_time and fdn_enterprise_histories.end_time',
                                org_id, time)}

  def copy_data(obj)
    #############################
    #COMMON COLUMNS
    ENT_COLUMNS.each do |column|
      self.send("#{column}=", obj.send(column))
    end
    ##############################
    #SPECIAL COLUMNS
    self.ent_id = obj.id
    self.start_time = Time.now
    self.end_time = '2999-12-31 23:59:59'
    self.save
    ##############################
    #ORGNIZATION
    if self.id != nil
      @org_his = Fdn::OrganizationHistory.where("resource_type = 'Fdn::EnterpriseHistory' and resource_id = ? " ,self.id)
      if @org_his.size != 0
        @org_his.each do |oh|
          oh.destroy
        end
      end
    end
    @org = Fdn::OrganizationHistory.create(:resource_type => 'Fdn::EnterpriseHistory',
                                           :resource_id=>self.id,
                                           :code => obj.organization.code,
                                           :name => obj.organization.name,
                                           :short_name => obj.organization.short_name,
                                           :start_time => self.start_time,
                                           :end_time => self.end_time,
                                           :lock_version => 0)


    ##############################
    #INVESTORS
    self.investors.clear
    obj.investors.each do |inv|
      self.investors.build(inv.attributes.select { |k, v| INV_COLUMNS.include?(k) })
    end
    ##############################
    #INDUSTRIES
    copy_industries(obj)
    ##############################
    #RESULTS
    copy_results(obj)
    ##############################
    #INDIVIDUALS
    #ONLY FOREIGN ENT
    copy_individuals(obj)

    save
  end


  def copy_individuals(obj)
    self.fdn_ent_individuals.clear
    obj.fdn_ent_individuals.each do |ind|
      self.fdn_ent_individuals.build(:individual_name => ind.individual_name,
                                     :actual_investor => ind.actual_investor,
                                     :last_id => ind.last_id)
    end
  end

  def copy_results(obj)
    self.results.clear
    obj.results.each do |result|
      self.results.build(:row_template_id => result.row_template_id, :value => result.value,:foreign_currency=>result.foreign_currency)
    end
  end

  def copy_industries(obj)
    self.industries.clear
    obj.industries.each do |ind|
      self.industries.build(:industry_id => ind.industry_id, :seq => ind.seq)
    end
    self.save
  end



  #{:date=>Thu, 21 Mar 2013, :vs=>"month", :vs_date=>Thu, 21 Feb 2013, :sasac_id=>1, :org_id=>1,
  #                                                              :org_name=>"南京市人民政府国有资产监督管理委员会"}
  # 唉，写sql语句吧
  #def search_ent_ent_level(h)
  #  org = Fdn::Organization.find(h[:org_id])
  #  children = org.with_hierarchy.all_descendants.group_by {|x| x.resource.ent_level_value}
  #  arr = []
  #  children.each do |lvl|
  #    arr << [lvl,children["lvl"].size,]
  #  end
  #
  #end
  #
  #def search_ent_ent_type(h)
  #
  #end
  #
  #def search_ent_org_type(h)
  #
  #end
  #
  #def search_ent_main_ind(h)
  #
  #end



end
