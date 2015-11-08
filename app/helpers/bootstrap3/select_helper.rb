#coding: utf-8
module Bootstrap3::SelectHelper
  extend ActiveSupport::Concern

  def select_search_include_tag
    output = javascript_include_tag('/js/plugins/chosen/chosen.jquery.js')
    output << stylesheet_link_tag('/css/plugins/chosen/chosen.css')
    output << javascript_tag("$('.chosen-select').chosen('.chosen-select');")
  end
end