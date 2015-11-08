#coding: utf-8
module Bootstrap3::LixiangTestHelper
  #extend ActiveSupport::Concern

  #引用
  def block_quote(value)
    content_tag('blockquote') do
      content = ''
      content << content_tag('p', value)
      raw content
    end
  end

  #被删除的文本
  def del_text(value)
    content = ''
    content << content_tag('del', value)
    raw content
  end

  def time_line(date,&block)
    result = ''
    content = ''
    result << content_tag('div', nil, class: "ibox-content timeline") do
      content_tag('div', nil, class: "timeline-item") do
        content_tag('div', nil, class: "row") do
          content << content_tag('div', nil, class: "col-xs-3 date") do
            content_tag('i', nil, class: "fa fa-list") + content_tag('p') + content_tag('small', date, class: "text-navy")
          end
          content << content_tag('div', nil, class: "col-xs-7 content") do
            capture(&block) if block
          end
          raw content
        end
      end
    end
    raw result
  end

end