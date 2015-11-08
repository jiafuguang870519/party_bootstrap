module Fdn
  class UserInformation < ActiveRecord::Base
    #acts_as_flex_attr

   validates_numericality_of :tel,:mobile, :on => :update, :if => :self_update?



    belongs_to :user
       #附件
    has_many :file_resources, :class_name => "Fdn::FileResource", :as=>:resource, :dependent=>:destroy
    accepts_nested_attributes_for :file_resources
    #validate :email,:presence=>true
    validates_presence_of :email, :on => :update, :if => :self_update?
    validates_presence_of :tel, :on => :update, :if => :self_update?
    validates_presence_of :mobile, :on => :update, :if => :self_update?

    def self_update?
      self.user_id == self.updated_by
    end

  end
end

# == Schema Information
#
# Table name: fdn_user_informations
#
#  id          :integer(4)      not null, primary key
#  full_name   :string(255)
#  tel         :string(255)
#  mobile      :string(255)
#  fax         :string(255)
#  address     :string(255)
#  postal_code :string(255)
#  email       :string(255)
#  user_id     :integer(4)
#  created_at  :datetime
#  updated_at  :datetime
#  created_by  :integer(4)
#  updated_by  :integer(4)
#

