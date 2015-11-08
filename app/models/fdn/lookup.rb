#coding: utf-8
module Fdn
  class Lookup < ActiveRecord::Base
    validates_presence_of :code, :value
    validates_uniqueness_of :code, :value,  :scope => :type, on: :create
    liquid_methods :value

    scope :available, -> { where("status='Y'").order("id") }
    scope :by_code, proc {|code| where('code = ?', code)}
    #scope :y, where("status='Y'")

    SEX_LOOKUP = [["男","M"],["女","F"]]

    UPLOAD_EXPFILE_TEMP_PATH =  Rails.root.join("attAcHmS","temp", "jiuqi", "express_report")
    UPLOAD_BUDFILE_TEMP_PATH =  Rails.root.join("attAcHmS","temp", "jiuqi", "ent_budget")
    UPLOAD_ACCFILE_TEMP_PATH =  Rails.root.join("attAcHmS","temp", "jiuqi", "ent_account")
    UPLOAD_STATFILE_TEMP_PATH =  Rails.root.join("attAcHmS","temp", "jiuqi", "ent_statistic")

    MINUTE = '%H:%M'
    LONG_DATE =  '%Y-%m-%d'
    SHORT_DATE =  '%y-%m-%d'
    LONG_TIME = '%Y-%m-%d %H:%M:%S'
    SHORT_TIME = '%Y-%m-%d %H:%M'

    PAGE_LIMIT_COUNT = 5
    PAGE_PER_COUNT = 15

    OPTION_PROMPT = "<option value=''>请选择</option>"

    WEEK_NAME={0=>'日',1=>'一',2=>'二',3=>'三',4=>'四',5=>'五',6=>'六'}

    BG_COLOR={1=>'#acd689',2=>'#f47a5d',3=>'#fff579',4=>'#6cd0f7',5=>'#9996c9',6=>'#ef67a7',7=>'#c59031',8=>'#e2d200',9=>'#57bc83',10=>'#8fd8f8',11=>'#f7aece',12=>'#f4768d',13=>'#ffc30e',14=>'#bcb6b6',15=>'#9cd3b0',16=>'#fff8ae',17=>'#fff8ae',18=>'#fff8ae',19=>'#fff8ae',20=>'#fff8ae',21=>'#fff8ae',22=>'#fff8ae',23=>'#fff8ae',24=>'#fff8ae',19=>'#fff8ae',25=>'#fff8ae'}

    NO_LIMIT_TIME = '2099-12-31'

    MSG_TYPE_MSG = 'msg'
    MSG_TYPE_SMS = 'sms'
    SMS_COUNTRY_CODE = "+86"
    SMS_END_TEXT = "[系统短信]"
    
    def self.select_y
      available.map{|l| [l.value, l.code]}
    end

    def self.select_id_y
      available.map{|l| [l.value, l.id]}
    end

    def self.select_prompt_y
      [['请选择', '']] + available.map{|l| [l.value, l.code]}
    end

    def full_name
      "#{code}|#{value}"
    end

  end
end
# == Schema Information
#
# Table name: fdn_lookups
#
#  id          :integer(4)      not null, primary key
#  code        :string(255)
#  type        :string(255)
#  type_name   :string(255)
#  value       :string(255)
#  description :string(255)
#  status      :string(255)
#  start_date  :date
#  end_date    :date
#  seq         :integer(4)
#  created_at  :datetime
#  updated_at  :datetime
#  created_by  :integer(4)
#  updated_by  :integer(4)
#

