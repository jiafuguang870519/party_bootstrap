class Fdn::EntInvestorHistory < ActiveRecord::Base
  # #attr_accessible :title, :body
  belongs_to :investor_type, :class_name => 'Prs::Lookups::InvestorType', :foreign_key => 'org_type_code', :primary_key => 'code'
  belongs_to :ent, :class_name=>'Fdn::EnterpriseHistory'
  belongs_to :org, :class_name=>'Fdn::Organization'
  belongs_to :last_investor, :class_name => 'Prs::Investor', :foreign_key => 'last_id'
  def investor_org_name
    if org
      org.name
    else
      investor_name
    end
  end

  def investor_org_name=(attribute)
    if org_id
      self.investor_name = nil
    else
      self.investor_name = attribute
    end
  end
end
