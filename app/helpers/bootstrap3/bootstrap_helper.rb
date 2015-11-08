#coding: utf-8
module Bootstrap3::BootstrapHelper
  extend ActiveSupport::Concern

  # 为form 提供布局基础
  module Layout
    def self.included(base)
      base.class_eval do
        attr_accessor :layout, :layout_span, :seq, :max_columns, :max_spans

        def span_mapping
          case max_columns
            when 1
              3
            when 2
              2
            else
              1
          end
        end

        def _row(layout='1')
          if max_spans != 12 && max_spans != 9 && layout.split(':').length == 3
            raise 'max_spans must be 12 or 9 when using layout of 3 cols. '
          end

          #if layout.split(':').length > 3
           # raise 'the number of cols are bigger than 3 is not supported. '
          #end

          self.layout = layout
          if self.layout_span && self.layout_span.is_a?(Array)
            self.layout_span.clear
          else
            self.layout_span = []
          end
          self.seq = 0
          _calculate_layout
        end

        def _calculate_layout
          cols = self.layout.split(':').map { |s| s.to_i }
          cols.each do |c|
            self.layout_span << [span_mapping, ((max_spans / cols.sum) * c).floor - span_mapping]
          end
        end

        def _fetch_seq
          current_seq = self.seq
          self.seq += 1
          current_seq
        end

        def _label_span(seq)
          self.layout_span[seq||self.seq][0]
        end

        def _value_span(seq)
          self.layout_span[seq||self.seq][1]
        end

        protected :_calculate_layout, :_label_span, :_value_span, :_fetch_seq
      end
    end
  end

  # Button groups
  # 就是一个div， 里面的btn还是自己写
  # opts:
  #   type: vertical 默认为空，竖着排。。。诡异
  def btn_group(opts={}, &block)
    class_str = 'btn-group'
    class_str += ' btn-group-vertical' if opts.delete(:type) == 'vertical'

    render_div(merge_predef_class(class_str, opts), &block)
  end

  # 合并预定义class
  def merge_predef_class(class_str, options={})
    predef_class = class_str + ' '
    predef_class += (options.delete(:class) || options.delete(:ext_class) || '')

    {class: predef_class}.merge(options)
  end


  # Thumbnails Grids of images, videos, text, and more
  def thumbnails(&block)
    content_tag('ul', nil, class: 'thumbnails') do
      capture(&block) if block_given?
    end
  end

  def thumbnail(span=12, title=nil, description=nil, &block)
    content_tag('li', nil, class: "span#{span}") do
      content_tag('div', nil, class: 'thumbnail') do
        content = []
        content << content_tag('h5', title) unless title.blank?
        content << capture(&block) if block_given?
        content << content_tag('p', description) unless description.blank?
        content.join.html_safe
      end
    end
  end


  ##############################################################################
  protected

  def links(links, seperator=nil)
    result = []
    links.each do |l|
      if l[:url_method]== 'delete'
        result << bs_a(l)
      elsif l[:url_method]== 'confirm'
        result << bs_confirm_window(l[:url], l[:value], l[:params],'', l[:confirm], l[:tips])
      else
        result << bs_link_window(l[:url], l[:value], '', '')
      end
    end
    raw result.join seperator
  end


end