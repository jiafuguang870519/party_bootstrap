class Fdn::Homepage < ActiveRecord::Base
  ##attr_accessible :dashboard_id, :organization_id, :user_id

  belongs_to :dashboard
  belongs_to :organization
  belongs_to :user
end
