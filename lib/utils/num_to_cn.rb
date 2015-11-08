#coding: utf-8
# To change this template, choose Tools | Templates
# and open the template in the editor.
module Utils
  class NumToCn
    CN_NUMS_MAP = {'0' => '〇', '1' => '一', '2' => '二', '3' => '三', '4' => '四', '5' => '五', '6' => '六', '7' => '七', '8' => '八', '9' => '九', '年' => '年', '月' => '月', '日' => '日'}

    def self.num_to_cn(str=nil)
      #输入为空时间取当前时间短日期
      if str.nil?
        return get_cn_date
      else
        return num_to_upper(str)
      end
    end

    def self.num_to_upper(str)
      cn_str = ""
      str.to_s.scan(/./) do |c|
        cn_str = cn_str.concat(CN_NUMS_MAP[c])
      end
      return cn_str
    end

    def self.month_to_cn(p_month)
      if p_month<10
        num_to_upper(p_month)
      elsif (p_month == 10)
        "十"
      else
        "十" + num_to_upper(p_month - 10)
      end
    end

    def self.day_to_cn(p_day)
      if p_day<20
        month_to_cn(p_day)
      else
        num_to_upper(p_day / 10) + "十" + num_to_upper(p_day - 10 * (p_day / 10))
      end
    end

    def self.get_num_short_date
      date_str = ""
      date_str = date_str.concat(Time.now.strftime('%Y'))
      date_str = date_str.concat("年")
      date_str = date_str.concat(Time.now.strftime('%m').to_i.to_s)
      date_str = date_str.concat("月")
      date_str = date_str.concat(Time.now.strftime('%d').to_i.to_s)
      date_str = date_str.concat("日")
      return date_str
    end

    def self.get_num_year
      date_str = ""
      date_str = date_str.concat(Time.now.strftime('%Y'))
      date_str = date_str.concat("年")
      return date_str
    end

    def self.get_cn_date(year=Time.now.strftime('%Y').to_i, month=Time.now.strftime('%m').to_i, day=Time.now.strftime('%d').to_i)
      return num_to_upper(year) + "年" + month_to_cn(month) + "月" + day_to_cn(day) + "日"
    end
  end
end