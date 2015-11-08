#coding: utf-8
module Bootstrap3::TabHelper
  extend ActiveSupport::Concern

  include ActionView::Helpers::FormHelper

  class TabBuilder
    attr_accessor :tabs, :default_index, :options, :template

    def initialize(index, template, options={})
      @default_index, @options, @template = index, options, template
      @tabs = {}
    end

    def tab(label, &proc)
      @tabs[label] = proc
    end

    def to_s

      default_tab_options = {id: 'tabs', class: 'nav nav-tabs'}
      default_pill_options = {id: 'tabs', class: 'nav nav-pills'}

      style = @options.delete(:style)
      if style == 'pill'
        options = default_pill_options.merge(@options)
        if direction = options.delete(:direction)
          options[:class] += " nav-#{direction}"
        end

        tab_position_class = ''
      else
        options = default_tab_options.merge(@options)

        #如果是tabs，确定tab的position
        position = options.delete(:position)
        if position
          tab_position_class = "panel blank-panel tabs-#{position}"
        else
          tab_position_class = "panel blank-panel"
        end
      end

      @template.content_tag('div', nil, class: tab_position_class) do
        @template.content_tag('div', nil,class: "panel-heading") do
          @template.content_tag('div', nil,class: "panel-options") do
            tab_content = ''
            tab_content << @template.content_tag('ul', nil, options) do
              tab_labels = ''
              @tabs.keys.each do |k|
                if style == 'pill'
                  tab_labels << render_pill_label(k, @tabs.keys.index(k) == @default_index.to_i, "#{options[:id]}-tab-#{@tabs.keys.index(k)}")
                else
                  tab_labels << render_tab_label(k, @tabs.keys.index(k) == @default_index.to_i, "#{options[:id]}-tab-#{@tabs.keys.index(k)}")
                end
              end
              @template.raw tab_labels
            end

            tab_content << @template.content_tag('div', nil, class: 'tab-content') do
              tab_panes = ''
              @tabs.values.each do |v|
                if style == 'pill'
                  tab_panes << render_pill_content(@tabs.values.index(v) == @default_index.to_i, "#{options[:id]}-tab-#{@tabs.values.index(v)}", &v)
                else
                  tab_panes << render_tab_content(@tabs.values.index(v) == @default_index.to_i, "#{options[:id]}-tab-#{@tabs.values.index(v)}", &v)
                end
              end
              @template.raw tab_panes
            end

            @template.raw tab_content
          end
        end
      end

    end

    private

    def render_tab_label(title, show, link_id)
      @template.content_tag('li', nil, (show ? {class: 'active'} : {})) do
        @template.link_to(title.html_safe, "##{link_id}", 'data-toggle'.to_sym => "tab")
      end
    end

    def render_pill_label(title, show, link_id)
      @template.content_tag('li', nil, (show ? {class: 'active'} : {})) do
        @template.link_to(title.html_safe, "##{link_id}", 'data-toggle'.to_sym => "pill")
      end
    end

    def render_tab_content(show, link_id, &proc)
      options = {class: "tab-pane #{show ? 'active' : ''}", id: link_id}
      @template.content_tag('div', nil, options) do
        @template.capture(&proc) if proc
      end
    end

    alias_method :render_pill_content, :render_tab_content
  end

  #显示tab页
  #index: 默认显示第几个标签
  #options:
  #  style: pill, tab，默认tab
  #  position: below, left, right 如果想控制tab的方向，用这个，只在tabs下有效
  #  direction: stacked 只在pills下有效
  def tabs(index=0, options={}, &proc)
    builder = TabBuilder.new(index, self, options)
    capture(builder, &proc)
    builder
  end


end