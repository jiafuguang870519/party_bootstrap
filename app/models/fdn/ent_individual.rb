class Fdn::EntIndividual < ActiveRecord::Base
  ##attr_accessible :actual_investor, :ent_id, :individual_name

  #比较本次记录和ppr的子类individual字段
  def compare_ind_column(column)
    #if self.last_id != nil
    #  ind_last = Prs::PprIndividual.find(self.last_id)
    #  if ind_last != nil
    #    if self.send(column) == ind_last.send(column)
    #      return 'true'
    #    else
    #      return 'false'
    #    end
    #  end
    #else
    #  return 'false'
    #end
    @ent_latests = Fdn::EnterpriseHistory.where("ent_id =? and end_time != '2999-12-31 23:59:59' ", self.ent_id).order("start_time DESC")#.first
    if @ent_latests.size != 0
      @ent_latest = @ent_latests.first
    else
      @ent_latest = Fdn::EnterpriseHistory.where("ent_id =? and end_time = '2999-12-31 23:59:59' ", self.ent_id).first
    end
    ind_last = Fdn::EntIndividualHistory.where("ent_id = ? and last_id = ?",@ent_latest.id,self.last_id)
    if ind_last.size != 0
      if self.send(column) == ind_last.first.send(column)
        return 'true'
      else
        return 'false'
      end
    end
  end

end
