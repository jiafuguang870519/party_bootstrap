#coding: utf-8
class Fdn::EntResult < ActiveRecord::Base

  belongs_to :ent ,:class_name=>'SupervisorDept'
  belongs_to :enterprise
  belongs_to :row_template , :class_name => 'Prs::RowTemplate' , :foreign_key => 'row_template_id'
  belongs_to :currency, :class_name => 'Fdn::Lookups::Currency', :foreign_key => 'currency_code', :primary_key => 'code'


  def compare_result_column(i,column)
    @ent_latests = Fdn::EnterpriseHistory.where("ent_id =? and end_time != '2999-12-31 23:59:59' ", self.ent_id).order("start_time DESC")#.first
    if @ent_latests.size != 0
      @ent_latest = @ent_latests.first
    else
      @ent_latest = Fdn::EnterpriseHistory.where("ent_id =? and end_time = '2999-12-31 23:59:59' ", self.ent_id).first
    end
    if !@ent_latest.nil?
      result_last = Fdn::EntResultHistory.where("ent_id = ? and row_template_id = ?",@ent_latest.id,i)
      if result_last.size != 0
        if result_last.first.send(column) == self.send(column)
          return 'true'
        else
          return 'false'
        end
      end
    end
  end
end
