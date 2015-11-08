#coding: utf-8
class Fdn::Legend < ActiveRecord::Base
  LEGEND_TYPE = [['国资动态','gov'], ['业务学习','yewu']]#[['通知公告','gonggao'], ['国资小新','xiaoxin']]#, ['国资智库','zhiku']
  LEGEND_ENT_TYPE = [['企业动态','qiye']]
  DEPT = [%w(发展规划 FZGHCCZ FZGHCKY), %w(产权管理 CQCCZ CQCKY), %w(经营预算 JYYSCCZ JYYSCKY), %w(业绩考核 YJKHCCZ YJKHCKY), %w(组织宣教 ZZXJCCZ ZZXJCKY), %w(安全生产 AQSCCCZ AQSCCKY)]
  belongs_to :creator, :class_name => 'Fdn::User', foreign_key: 'created_by'

  belongs_to :organization, :class_name => 'Fdn::Organization', foreign_key: 'org_id'

  has_many :file_resources,->{ where("fdn_file_resources.display_name = 'img'") }, :class_name => 'Fdn::FileResource',:as => :resource, :dependent => :destroy#,:conditions => "fdn_file_resources.display_name = \'img\'"
  accepts_nested_attributes_for :file_resources, :allow_destroy => true, reject_if: proc { |attributes| attributes['ffx'].blank? || !attributes['ffx'].content_type.include?('image')}

  has_many :file,->{ where("fdn_file_resources.display_name = 'file'") },:class_name => 'Fdn::FileResource', :as => :resource, :dependent => :destroy#,:conditions => "fdn_file_resources.display_name = \'file\'"
  accepts_nested_attributes_for :file, :allow_destroy => true

  scope :search_org_id, ->(org_id) {where(org_id: org_id)}
  scope :ent_resources, -> {joins(:organization).where(fdn_organizations:{resource_type:'Fdn::Enterprise'})}
  scope :dept_resources, -> {joins(:organization).where(fdn_organizations:{resource_type:'Fdn::Dept'})}
  # scope :gonggao, -> {where(type_code:'gonggao')}
  scope :hefei, -> {where(type_code:'gov')}

  scope :quxian, -> {where(type_code:'quxian')}
  scope :yewu, -> {where(type_code:'yewu')}
  scope :qiye, -> {where(type_code:'qiye')}
  scope :district, -> {where(type_code: ['quxian', 'yewu'])}
  # scope :xiaoxin, -> {where(type_code:'xiaoxin')}
  # scope :zhiku, -> {where(type_code:'zhiku')}

  default_scope -> {order('created_at desc')}

  def images
    file_resources.select{|x|x.ffx_content_type.include?('image')}
  end

  def type_value
    Fdn::Legend::LEGEND_TYPE.select{|arr|arr[1]==type_code} if type_code
  end

  def self.split_dept
    arr = Fdn::Legend::DEPT.map{|x|[x[0]]}
    Fdn::Legend.dept_resources.each do |legend|
      DEPT.each_with_index do |d, index|
        if legend.creator.send("is_a_#{d[1]}?") || legend.creator.send("is_a_#{d[2]}?")
          arr[index] << legend
          break
        end
      end
    end
    arr
  end
end
