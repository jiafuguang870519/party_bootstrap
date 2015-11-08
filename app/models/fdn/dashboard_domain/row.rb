#coding: utf-8
class Fdn::DashboardDomain::Row

  attr_accessor :columns
  # To change this template use File | Settings | File Templates.
  def initialize(columns=[])
    self.columns = columns
  end

  def to_s
    output = '<div class="widget-row row-fluid">'

    columns.each do |c|
      output << c.to_s
    end
    output << '</div>'
    output
  end
end