#coding: utf-8
class Fdn::Logger < ActiveRecord::Base

  attr_accessor :zzz_full_name_cont

  belongs_to :actor, :class_name=>'Fdn::User', :foreign_key=>'user_id'
  #has_one :person, :through => :actor
  belongs_to :right_type, :class_name=>'Fdn::Lookups::RightType', :foreign_key => 'controller', :primary_key => 'code'
  scope :username_like, lambda { |username| includes(:actor).where("fdn_users.username like ?", "%#{username}%") }
  scope :fullname_like, lambda { |fullname| includes(:actor => :user_information).where("fdn_user_informations.full_name like ?", "%#{fullname}%") }
  scope :act_date_between, lambda { |date_b, date_e|  where(['act_at between ? and ?', date_b + ' 00:00:00', date_e + ' 23:59:59']) }
  scope :date_begin, proc {|date_b| where('act_at >= ?', date_b + ' 00:00:00')}
  scope :date_end, proc {|date_e| where('act_at <= ?', date_e + ' 23:59:59')}
  #scope :username_excpet, -> {includes(:actor).where("fdn_users.username != 'ghost'") }

  def self.more_search(params, page=nil, limit=nil)
    r = Fdn::Logger
    if !params[:zzz_full_name_cont].blank?
      r = r.fullname_like(params[:zzz_full_name_cont])
    end
    if page
      r = r.order('act_at desc').paginate(:page=> page)
    elsif limit
      r = r.order('act_at desc').limit(limit)
    else
      r = r.order('act_at desc')
    end

    r
  end
end
