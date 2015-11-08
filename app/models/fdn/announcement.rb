class Fdn::Announcement < ActiveRecord::Base
  belongs_to :creator, :class_name => 'Fdn::User', foreign_key: 'created_by'
  default_scope -> {order('created_at desc')}

  has_many :file_resources, :class_name => 'Fdn::FileResource', :as => :resource, :dependent => :destroy
  accepts_nested_attributes_for :file_resources, :allow_destroy => true
end
