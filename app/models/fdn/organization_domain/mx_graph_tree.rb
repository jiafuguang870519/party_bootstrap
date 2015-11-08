module Fdn::OrganizationDomain::MxGraphTree
  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do

    end
  end

  module ClassMethods

  end

  def to_mx_json_tree(top=self, time=Time.now)
    self.with_hierarchy(Fdn::OrgHierarchy.main.first.id, time)
    json_str = []
    json_str << mx_org_info_json(time)
    json_str << mx_org_inv_json(time)
    json_str << mx_org_be_inv_json(top, time)

    result = []
    result << "{#{json_str.join(',')}}"

    self.children.sort! { |x, y|
      x_inv = x.be_invested_at(time).detect { |inv| inv[:id] == self.id }
      #p x_inv
      #p y.be_invested_at(time)
      y_inv = y.be_invested_at(time).detect { |inv| inv[:id] == self.id }
      if x_inv && y_inv
        r = y_inv[:percentage] <=> x_inv[:percentage]
        r = y_inv[:amt] <=> x_inv[:amt] if result == 0
        r
      else
        1
      end
    }.each do |o|
      result << o.to_mx_json_tree(top, time)
    end
    result.join(',')
  end

  private
  def mx_org_info_json(time)
    results = []
    results << "name: '#{self.name}'"
    results << "id: 'o#{self.id}'"
    results << "type: '#{self.is_ent? ? self.resource.ent_type_code : '000'}'"
    results << "pprStatus: '#{self.is_ent? ? self.resource.ppr_status_code : '1'}'"
    results << "opStatus: '#{self.is_ent? ? self.resource.operate_status_code : 'OP'}'"
    results << "regAmt: #{self.is_ent? ? self.resource.reg_amt : 0}"
    if self.be_invested_at(time).size > 0
      results << "parentInv: #{self.be_invested_at(time).detect{|inv| inv[:id] == self.parent.id}[:percentage]}"
    end
    results.join(',')
  end

  def mx_org_inv_json(time)
    invs = self.invested_at(time)

    result = 'children:['
    children_results = []
    self.children.each do |org|
      inv = invs.detect { |inv| inv[:ent].id == org.resource_id }
      if inv
        children_results << "{id: 'o#{org.id}', percentage: #{inv[:percentage]}, amt: #{inv[:amt]}}"
      else
        children_results << "{id: 'o#{org.id}', percentage: 0, amt: 0}"
      end
      invs.delete(inv)
    end
    result << children_results.join(',')
    result << '],'
    result << 'crossInvestment:['
    children_results = []
    invs.each do |inv|
      children_results << "{id: 'o#{inv[:ent].organization.id}', percentage: #{inv[:percentage]}, amt: #{inv[:amt]}}"
    end
    result << children_results.join(',')
    result << ']'
  end

  def mx_org_be_inv_json(top, time)
    invs = self.be_invested_at(time)
    des = top.all_descendants.push(top).map { |o| o.id }
    invs = invs.delete_if { |inv| des.include?(inv[:id]) }

    result = 'beCrossInvestment:['
    children_results = []
    invs.sort! { |x, y|
      r = y[:percentage] <=> x[:percentage]
      r = y[:amt] <=> x[:amt] if result == 0
      r
    }

    invs.each do |inv|
      if inv[:id] && inv[:type] <= '003'
        children_results << "{name: '#{inv[:name]}', percentage: #{inv[:percentage]}, amt: #{inv[:amt]}}"
      end
    end
    result << children_results.join(',')
    result << '],'
    result << 'beOuterInvestment:['
    children_results = []
    invs.each do |inv|
      unless inv[:id] && inv[:type] <= '003'
        children_results << "{name: '#{inv[:name]}', percentage: #{inv[:percentage]}, amt: #{inv[:amt]}}"
      end
    end
    result << children_results.join(',')
    result << ']'
  end
end