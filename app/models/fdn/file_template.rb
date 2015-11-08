#coding: utf-8
module Fdn
  class FileTemplate < ActiveRecord::Base
    FILE_TYPES = [['必须','REQ'], ["标准",'STD'],['其他','OTH']]
    DEF_CLASS = 'DEF'
    LEG_CLASS = 'LEG'

    scope :std_templates, lambda { |resource_type| where("resource_type = ? and status = 'Y' and template_type <> 'OTH'", resource_type).order("seq") }
    scope :template_class_value, lambda { |resource_type,template_class| where("resource_type = ? and template_class = ?",resource_type, template_class).order("seq") }
    scope :template_type_value, lambda { |resource_type,template_type| where("resource_type = ? and template_type = ?",resource_type, template_type).order("seq") }
    scope :std_class_templates, lambda { |resource_type, file_class | where(["resource_type = ? and template_class = ?  and status = 'Y' and template_type <> 'OTH'", resource_type, file_class]).order("seq") }
    scope :req_templates, lambda {|resource_type| where("resource_type = ? and status = 'Y' and template_type = 'REQ'", resource_type).order("seq")}
    scope :req_class_templates,lambda { |resource_type, file_class | where(["resource_type = ? and template_class = ?  and status = 'Y' and template_type = 'REQ'", resource_type, file_class]).order("seq") }
    scope :oth_templates, lambda{ |resource_type| where("resource_type = ? and status = 'Y' and template_type = 'OTH'", resource_type).order("seq")}
    scope :oth_class_templates,lambda { |resource_type, file_class | where(["resource_type = ? and template_class = ?  and status = 'Y' and template_type = 'OTH'", resource_type, file_class]).order("seq") }
  end
end

