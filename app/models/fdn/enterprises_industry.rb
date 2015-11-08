class Fdn::EnterprisesIndustry < ActiveRecord::Base
  belongs_to :enterprise
  belongs_to :industry, :class_name => "Prs::Lookups::EntIndustry" , :foreign_key => 'industry_id', :primary_key => 'code'
end
