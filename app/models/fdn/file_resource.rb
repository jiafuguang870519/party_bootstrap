class Fdn::FileResource < ActiveRecord::Base
  #acts_as_flex_attr

  belongs_to :resource, :polymorphic=>true
  belongs_to :file_template, :class_name => 'Fdn::FileTemplate'
  belongs_to :file_class, :class_name => 'Fdn::FileClass'

  #has_one :sam_work_card, :class_name=>'Sam::WorkCard', :foreign_key=>"id",:primary_key=>"resource_id"
  #has_one :hr_el_manager, :class_name=>'Hr::ElManager', :foreign_key=>"id",:primary_key=>"resource_id"
  #has_one :rad_survey, :class_name=>'Rad::Survey', :foreign_key=>"id",:primary_key=>"resource_id"
  #has_one :sam_report_draft, :class_name=>'Sam::ReportDraft', :foreign_key=>"id",:primary_key=>"resource_id"
  #has_one :sam_report_summary, :class_name=>'Sam::ReportSummary', :foreign_key=>"id",:primary_key=>"resource_id"
  #has_one :sam_bod_resolution, :class_name=>'Sam::BodResolution', :foreign_key=>"id",:primary_key=>"resource_id"
  #has_one :flex_attr ,:class_name=>'Fdn::FlexAttribute', :foreign_key=>"id",:primary_key=>"resource_id"
  attr_accessor :after_ffx, :ent_name, :other_class
  #after_create :save_ffx_file
  #附件上传
  has_attached_file :ffx,
                    :url=> '/attachments/:class/:attachment/:id/:style.:extension',
                    :path=>':rails_root/attAcHmS/:class/:id_partition/:style/:basename.:extension'
  do_not_validate_attachment_file_type :ffx
  validates_attachment_size :ffx, :less_than=>2048.megabytes, :unless=>Proc.new {|a|  a.ffx_file_size.nil?}
  scope :by_resource_id, lambda { |resource_id| where("resource_id = ?", resource_id) }
  scope :by_resource_ids, proc { |ids| where('fdn_file_resources.resource_id in (?)', ids) }
  scope :ent_type, -> { where("fdn_file_resources.resource_type='Fdn::Enterprise'") }
  #has_many再has_many file时会出现先保存文件后保存记录的问题。使用after_ffx来手工保存ffx
  def save_ffx_file
    unless after_ffx.blank?
      self.ffx = after_ffx
      self.save
    end
  end

  def downloadable?(user)
    true
  end

  def downloadable_name
    display_name || ffx_file_name
  end

  def temp_file_name
    if !self.file_template_id.blank?
      return self.file_template.template_name
    else
      return self.display_name
    end
  end

end
