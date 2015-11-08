#coding: utf-8
module Fdn::EnterpriseDomain::Report
  # To change this template use File | Settings | File Templates.
  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do

    end
  end

  module ClassMethods

  end

  #ent_id:一级企业id
  #date:截止日期
  #return a Hash
  #{
  #   ents: [{      企业列表
  #     id:         id
  #     name:       name of organization
  #     level:      ent_level_code
  #     reg_amt:    reg_amt
  #     inv_amt:    acutal_inv_amt of investor
  #     per:        percentage of investor
  #     status:     operate_status_code
  #     seq:        relative sequence, lv2: [], lv3: (), lv4: num, lv5: num-num, lv6: num-num-num, lv7: num-num-num-num
  #     abs_seq:    absolute sequence, num from 1-n
  #   }]
  #   total: {
  #     count:      count of ents, except lv1
  #     cross:      交叉持股
  #     name:       name of lv1
  #     time:       date
  #   }
  #   subtotal: [{
  #     level:      ent_level_code
  #     count:      count of lvN
  #     control:    控股数量
  #     no_control: 参股数量
  #   }]
  #}
  #通讯录
  def contact_tree_list_report(date=Date.today)
    time = date.to_time.end_of_day
    result = {
        ents: []
    }
    root_org = self.organization
    @root_user = Fdn::User.by_org_id(root_org.id)
    i = 1
    if !root_org.root?
      @parent_org = Fdn::Organization.find(root_org.id).ancestors.reverse
      @parent_org.each do |p_org|
        @users = Fdn::User.by_org_id(p_org.id)
        @users.each do |user|
          result[:ents] << {
              id: p_org.id,
              name: p_org.name,
              level: (p_org.resource_type == 'Fdn::Enterprise' ? p_org.resource.ent_level_code.to_i : ''),
              short_name: p_org.short_name,
              seq: '0',
              abs_seq: i,
              user_name: user.user_information.full_name,
              post: user.user_information.post,
              tel: user.user_information.tel,
              mobile: user.user_information.mobile,
              fax: user.user_information.fax,
              im_soft: user.user_information.im_soft
          }
        end
        i = i + 1
      end
    end

    @root_user.each do |user|
      result[:ents] << {
          id: root_org.id,
          name: root_org.name,
          level: self.ent_level_code.to_i,
          short_name: root_org.short_name,
          seq: '0',
          abs_seq: i,
          user_name: user.user_information.full_name,
          post: user.user_information.post,
          tel: user.user_information.tel,
          mobile: user.user_information.mobile,
          fax: user.user_information.fax,
          im_soft: user.user_information.im_soft
      }
    end
    index = 0
    root_org.all_descendants.sort! { |x, y|
      r = x.resource[:ent_level_code] <=> y.resource[:ent_level_code]
      r = x[:id] <=> y[:id] if r == 0
      r
    }.each do |child|
      if child[:ent] && child[:ent].organization.with_hierarchy(nil, time).parent.id != root_org.id
        reverse = true
      else
        reverse = false
      end
      get_children_tree_object(child, time, result, '0', index) unless reverse
      index += 1
    end
    result
  end

  def search_ent_report(date=Date.today, arr)
    time = date.to_time.end_of_day
    arr = arr.split(",")
    result = {
        ents: [],
        total: {
            count: 0,
            cross: 0,
            name: '',
            time: ''
        },
        subtotal: []
    }
    root_org = self.organization

    root_inv = root_org.be_invested_at(time).detect { |inv| inv[:id] == self.main_inv_org_id }
    h = Hash.new
    h[:name] = self.name
    arr.each do |a|
      a = "industry_names" if a == "main_ind_value"
      h[a.to_sym] = self.send(a)
    end
    result[:ents] << h

    result[:total][:name] = root_org.name
    result[:total][:time] = date.strftime('%Y年%m月%d日')

    index = 0
    root_org.invested_at(time).sort! { |x, y|
      r = y[:percentage] <=> x[:percentage]
      r = y[:amt] <=> x[:amt] if r == 0
      r
    }.each do |child|
      if child[:ent].organization.with_hierarchy(nil, time).parent.id != root_org.id
        reverse = true
      else
        reverse = false
      end
      search_ent_object(child, time, result, '0', index, arr) unless reverse
      index += 1
    end
    result
  end


  def tree_list_report(date=Date.today)
    time = date.to_time.end_of_day
    result = {
        ents: [],
        total: {
            count: 0,
            cross: 0,
            name: '',
            time: ''
        },
        subtotal: []
    }
    root_org = self.organization

    root_inv = root_org.be_invested_at(time).detect { |inv| inv[:id] == self.main_inv_org_id }
    result[:ents] << {
        id: self.id,
        name: root_org.name,
        level: self.ent_level_code.to_i,
        reg_amt: self.reg_amt,
        inv_amt: root_inv[:amt],
        per: root_inv[:percent],
        status: self.operate_status.value,
        seq: '0',
        abs_seq: 0
    }

    result[:total][:name] = root_org.name
    result[:total][:time] = date.strftime('%Y年%m月%d日')

    index = 0
    root_org.invested_at(time).sort! { |x, y|
      r = y[:percentage] <=> x[:percentage]
      r = y[:amt] <=> x[:amt] if r == 0
      r
    }.each do |child|
      if child[:ent].organization.with_hierarchy(nil, time).parent.id != root_org.id
        reverse = true
      else
        reverse = false
      end
      get_tree_object(child, time, result, '0', index, 1, reverse)
      index += 1
    end
    result #.uniq
  end

  private
  def search_ent_object(ent, time, result, parent_seq, current_seq, arr)
    org = ent[:ent].organization
    seq = get_relative_seq(ent[:ent].ent_level_code.to_i, parent_seq, current_seq)

    h = Hash.new
    h[:name] = org.name
    arr.each {|a| h[a.to_sym] = org.resource.send(a)}
    result[:ents] << h

    index = 0
    org.invested_at(time).sort! { |x, y|
      r = y[:percentage] <=> x[:percentage]
      r = y[:amt] <=> x[:amt] if r == 0
      r
    }.each do |child|
      if child[:ent].organization.with_hierarchy(nil, time).parent.id != org.id
        reverse = true
      else
        reverse = false
      end
      search_ent_object(child, time, result, seq, index, arr) unless reverse
      index += 1
    end

  end

  #@param ent: return value of invested_at, a hash
  def get_tree_object(ent, time, result, parent_seq, current_seq, level, reverse)
    org = ent[:ent].organization
    seq = get_relative_seq(level+1, parent_seq, current_seq)
    result[:ents] << {
        id: ent[:ent].id,
        name: org.name,
        level: level+1,
        reg_amt: ent[:ent].reg_amt,
        inv_amt: ent[:amt],
        per: ent[:percentage],
        status: ent[:ent].operate_status.value,
        seq: seq,
        abs_seq: result[:ents].size
    }

    if result[:ents].select { |e| e[:id] == ent[:ent].id }.size > 1
      result[:total][:cross] += 1
    else
      result[:total][:count] += 1
      if subtotal = result[:subtotal].detect { |subtotal| subtotal[:level] == ent[:ent].ent_level_code.to_i }
        subtotal[:count] += 1
        ent[:ent].ent_type_code <= '003' ? subtotal[:control] += 1 : subtotal[:no_control] += 1
      else
        result[:subtotal] << {
            level: ent[:ent].ent_level_code.to_i,
            count: 1,
            control: (ent[:ent].ent_type_code <= '003' ? 1 : 0),
            no_control: (ent[:ent].ent_type_code <= '003' ? 0 : 1)
        }
      end
    end
    unless reverse
      index = 0
      org.invested_at(time).sort! { |x, y|
        r = y[:percentage] <=> x[:percentage]
        r = y[:amt] <=> x[:amt] if r == 0
        r
      }.each do |child|
        if child[:ent].organization.with_hierarchy(nil, time).parent.id != org.id
          reverse = true
        else
          reverse = false
        end
        get_tree_object(child, time, result, seq, index, level+1, reverse)
        index += 1
      end
    end
  end

  def get_children_tree_object(org, time, result, parent_seq, current_seq)
    seq = get_relative_seq(org.resource.ent_level_code.to_i, parent_seq, current_seq)
    check = 'false'
    @abs_seq = result[:ents].last[:abs_seq] + 1
    @users = Fdn::User.by_org_id(org.id)
    result[:ents].each do |ent|
      if ent[:id] == org.id
        check = 'true'
      end
    end
    if check == 'false'
      @users.each do |user|
        result[:ents] << {
            id: org.id,
            name: org.name,
            level: org.resource.ent_level_code.to_i,
            short_name: org.short_name,
            seq: seq,
            abs_seq: @abs_seq,
            user_name: user.user_information.full_name,
            post: user.user_information.post,
            tel: user.user_information.tel,
            mobile: user.user_information.mobile,
            fax: user.user_information.fax,
            im_soft: user.user_information.im_soft
        }
      end
      index = 0
      org.all_descendants.sort! { |x, y|
        r = x.resource[:ent_level_code] <=> y.resource[:ent_level_code]
        r = x[:id] <=> y[:id] if r == 0
        r
      }.each do |child|
        if child[:ent] && child[:ent].organization.with_hierarchy(nil, time).parent.id != org.id
          reverse = true
        else
          reverse = false
        end
        get_children_tree_object(child, time, result, '0', index) unless reverse
        index += 1
      end

    end
  end

  def get_relative_seq(level, parent_seq, current_seq)
    case level
      when 2
        "[#{current_seq+1}]"
      when 3
        "(#{current_seq+1})"
      when 4
        "#{current_seq+1}、"
      else
        "#{parent_seq.sub('、', '')}-#{current_seq+1}"
    end
  end

end