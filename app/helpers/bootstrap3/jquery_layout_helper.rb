#coding: utf-8
module Bootstrap3::JqueryLayoutHelper
  #jquery Layout helper
  def jq_layout_west_page(options = {}, &block)
    tag = 'iframe'
    west_width = options[:west_width] || '200'
    west_close_width = options[:west_close_width] || '2'
    west_close_desc = options[:west_close_desc] || '展开'

    script = Array.new
    script << "var pageLayout;"
    script << "$(document).ready(function () {"
    script << "   pageLayout = $('body').layout({"
    script << "   west__size:#{west_width},"
    script << "   west__spacing_closed:#{west_close_width},"
    script << "   west__togglerLength_closed:	100,"
    script << "   west__togglerAlign_closed:	'top',"
    script << "   west__togglerContent_closed:'#{west_close_desc.split(%r{\s*}).join("<br/>")}',"
    script << "   west__togglerTip_closed:	'展开',"
    script << "   west__slideTrigger_open:	'mouseover'"
    script << "   });"
    script << "});"

    javascript_tag(script.join("\n")) + content_tag(tag, "", :class => "ui-layout-center", :id => options[:iframe_id], :name => options[:iframe_name], :width => "100%", :frameborder => "0", :scrolling => "auto", :src => options[:iframe_src]) + content_tag("div", {:class => "ui-layout-west"}, true, &block)
  end
end