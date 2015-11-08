#coding: utf-8
module Oa
  module Lookups
    class DocWord < Fdn::Lookup
      #has_and_belongs_to_many :templates, :class_name => 'Fdn::Template', :join_table=>'doc_words_templates',
      #                    :foreign_key => 'lookup_id', :association_foreign_key => 'template_id'
      #
      #has_many :doc_nos, :class_name => 'Oa::DocNo', :foreign_key => 'doc_word_code', :primary_key => 'code', :dependent => :destroy do
      #  def by_year(year)
      #    where("oa_doc_nos.year = ?", year)
      #  end
      #
      #  def current_year
      #    by_year(Date.today.year)
      #  end
      #end
      #
      #def current_num(year=Date.today.year)
      #  doc_no = self.doc_nos.by_year(year)
      #  if doc_no.empty?
      #    build_from_year(year)
      #    self.save
      #
      #    1
      #  else
      #    doc_no[0].current_num
      #  end
      #end
      #
      #def set_current_num(num, year=Date.today.year)
      #  doc_no = self.doc_nos.by_year(year)
      #  if doc_no.empty?
      #    doc_no = build_from_year(year)
      #    doc_no.current_num = num
      #  else
      #    doc_no[0].current_num = num
      #  end
      #  self.save
      #end
      #
      #def build_from_year(year)
      #  self.doc_nos.build(:year=>year, :start_num=>1, :current_num=>0)
      #end
      #
      #def build_from_current_year
      #  self.build_from_year(Date.today.year)
      #end
      #
      #has_one :current_doc_no, :class_name => 'Oa::DocNo', :foreign_key => 'doc_word_code', :primary_key => 'code', :conditions=>{:year=>Date.today.year}
      #accepts_nested_attributes_for :current_doc_no
      #
      #before_create :bc
      #def bc
      #  max_code = Oa::Lookups::DocWord.maximum('cast(code as signed)')
      #  self.code = max_code.to_i + 1
      #  self.type_name = "公文字"
      #  self.status = 'Y'
      #  self.start_date = Date.today
      #  self.description = self.value
      #end
      #
      #before_destroy :bd
      #def bd
      #  if Oa::SentDocument.find_by_doc_word_code(self.code)
      #    raise RuntimeError.new('can\'t delete it')
      #  end
      #end


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

