module Fdn
class WorkCalendar < ActiveRecord::Base
  #创建所选年份的日历
  def self.create_calendar(year)
    d1 = Date.new(year,1,1)
    d2 = d1.end_of_year

    d1.step(d2) { |date|
      Fdn::WorkCalendar.create(:year=>date.year, :qtr=>(date.mon/3.0).ceil, :month=>date.mon, :day_of_week=>(date.wday==0 ? 7 : date.wday), :day_name=>date,
        :is_working=> (date.wday == 0 || date.wday == 6) ? 0 : 1, :is_weekend=> (date.wday == 0 || date.wday == 6) ? 1 : 0, :is_holiday=>0 )
    }
  end

  #显示所选月份的日期，包括月初前在同一周的几天和月末后在同一周的几天
  def self.show_by_month(year, month)
    d1 = Date.new(year,month,1)
    first_day_of_week = d1 - ( (d1.wday==0 ? 7 : d1.wday) - 1)

    d2 = d1.end_of_month
    last_day_of_week = d2 + (7- (d2.wday==0 ? 7 : d2.wday) )

    all :conditions=>['day_name between ? and ?', first_day_of_week, last_day_of_week], :order=>'day_name'
  end

  def self.working_limit(start_date, limit)
    end_time = start_date
    limit.times { |i|
      begin
        end_time = end_time.advance(:days=>1)
        wc = Fdn::WorkCalendar.find_by_day_name(end_time.to_date)
      end while wc.is_working == 0
    }
    end_time
  end

  def self.calc_remaining_limit(start_date, end_date, limit)
    current_date = start_date
    used_days = 0
    #logger.info("pause test ccc:#{current_date.to_s}")
    limit.times { |i|
      begin
        current_date = current_date.advance(:days=>1)
        wc = Fdn::WorkCalendar.find_by_day_name(current_date.to_date)
        #logger.info("pause test ccc:#{i},#{wc.is_working} ")
      end while wc.is_working == 0
      if current_date.to_date > end_date.to_date
        break
      end
      used_days += 1
      #logger.info("pause test ccd:#{used_days} ")
    }
    #logger.info("pause test ccd:#{limit - used_days} ")
    return limit - used_days
  end

  def self.paused_working_limit(flow, current_index, remaining_limit)
    if current_index == 0
      #logger.info("pause test:#{flow.come_in_time.to_s},#{flow.pauses[current_index].paused_at.to_s},#{remaining_limit}")
      rl = calc_remaining_limit(flow.come_in_time, flow.pauses[current_index].paused_at, remaining_limit)
      if rl && rl >= 0
        if flow.pauses[current_index+1].nil?
          end_date = working_limit(flow.pauses[current_index].resumed_at, rl)
        else
          end_date = paused_working_limit(flow, current_index+1, rl)
        end
      else
        end_date = working_limit(flow.come_in_time, remaining_limit)
      end
    else
      if flow.pauses[current_index+1].nil?
        end_date = working_limit(flow.pauses[current_index].resumed_at, remaining_limit)
      else
        rl = calc_remaining_limit(flow.pauses[current_index].resumed_at, flow.pauses[current_index+1].paused_at, remaining_limit)
        if rl && rl >= 0
          end_date = paused_working_limit(flow, current_index+1, rl)
        else
          end_date = working_limit(flow.pauses[current_index].resumed_at, rl)
        end
      end
    end

    end_date
  end

  def self.flow_working_limit(flow, limit)
    #如果已暂停则返回空
    if flow.paused?
      return nil
      #如果从未暂停过则直接返回计算结果
    elsif flow.pauses.empty?
      return working_limit(flow.come_in_time, limit)
    else
      #logger.info("pause test:#{flow.id},#{limit}")
      return paused_working_limit(flow, 0, limit)
    end
  end
  
  #判断日期类型
  def checkday
    if self.is_working == 1
      return 1
    elsif self.is_weekend == 1
      return 2
    else
      return 3
    end
  end
  
end
end
