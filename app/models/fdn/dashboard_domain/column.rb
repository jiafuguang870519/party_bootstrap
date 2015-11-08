#coding: utf-8
class Fdn::DashboardDomain::Column

  attr_accessor :width, :contents

  def initialize(width=12, contents=[])
    self.width= width
    self.contents = contents
  end

  def to_s
    output = "<div class='widget-column span#{width}'>"

    contents.each do |c|
      output << c.to_s
    end
    output << '</div>'

    output
  end
end