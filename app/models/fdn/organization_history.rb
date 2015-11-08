class Fdn::OrganizationHistory < ActiveRecord::Base
  ##attr_accessible :ent_time, :start_time
  belongs_to :resource, :polymorphic => true
end
