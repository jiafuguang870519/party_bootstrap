#coding: utf-8
class Fdn::Notification < ActiveRecord::Base
  belongs_to :resource, :polymorphic => true
  #发送人
  belongs_to :sender, :class_name => 'Fdn::User', :foreign_key => 'created_by'
  scope :no_read, -> { where(:view_time => nil) }

  def read?
    return !self.view_time.nil?
  end
end
