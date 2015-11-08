class Oa::SentDocument < ActiveRecord::Base

  belongs_to :doc_type, :class_name => 'Oa::Lookups::DocType', :foreign_key => 'doc_type_code', :primary_key => 'code'
  belongs_to :secret_level, :class_name => 'Oa::Lookups::SecretLevel', :foreign_key => 'secret_level_code', :primary_key => 'code'
  belongs_to :doc_urgency, :class_name => 'Oa::Lookups::DocUrgency', :foreign_key => 'doc_urgency_code', :primary_key => 'code'
  belongs_to :doc_word, :class_name => 'Oa::Lookups::DocWord', :foreign_key => 'doc_word_code', :primary_key => 'code'
  belongs_to :gzw_doc_level, :class_name => 'Oa::Lookups::GzwDocLevel', :foreign_key => 'gzw_doc_level_code', :primary_key => 'code'

  belongs_to :creator, :class_name => 'Fdn::User', :foreign_key => 'created_by'
  belongs_to :updater, :class_name => 'Fdn::User', :foreign_key => 'updated_by'

  belongs_to :organization, :class_name => 'Fdn::Organization' ,:foreign_key => 'organization_id'
  belongs_to :print_org, :class_name => 'Fdn::Organization', :foreign_key => 'print_org_id'

  belongs_to :sent_doc_status, :class_name => 'Oa::Lookups::SentDocStatus', :foreign_key => 'status', :primary_key => 'code'

  has_many :file_resources, :class_name => 'Fdn::FileResource', :as => :resource, :dependent => :destroy
  accepts_nested_attributes_for :file_resources, :allow_destroy => true
end
