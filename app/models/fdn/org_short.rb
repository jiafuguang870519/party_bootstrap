class Fdn::OrgShort < ActiveRecord::Base
  belongs_to :organization, :class_name=>"Fdn::Organization", :foreign_key=>"organization_id"
  belongs_to :org, :class_name=>"Fdn::Organization", :foreign_key=>"act_dept_id"
  attr_accessor :organization_name
end
