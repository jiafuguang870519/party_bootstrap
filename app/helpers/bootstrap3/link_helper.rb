#coding: utf-8
module Bootstrap3::LinkHelper
  extend ActiveSupport::Concern

  DEFAULT_OPTIONS = {
      disabled: false,
      active: false,
      align: 'default'
  }

  REMOVED_OPTS = [:icon]

  #产生一个链接
  #options:
  #  value: 链接的显示文字
  #  disabled: true, false
  #  active: true, false
  #  align: default, left, right
  #  icon: 在按钮前面加图标，使用标准bootstrap图标，如图标名称为 icons-xxx，则传入 xxx即可，如果名称为 icons-xxx-yyy，则传入 xxx_yyy
  #  url: 按钮触发后的url，与js二选一
  #  js: 按钮触发后的js，与url二选一
  #  confirm: 按钮触发后弹出的确认字符串
  #  method: html方法, put, post ,delete
  #  其他符合html标准的options都可以传入，自动作为元素的options
  def bs_a(options={}, &block)
    opts = DEFAULT_OPTIONS.merge(options)
    content_tag('li', nil, render_li_options(opts.dup)) do
      content_tag('a', nil, render_a_options(opts.dup)) do
        raw render_a_content(opts) + (block ? capture(&block) : '')
      end
    end
  end

  ##############################
  # 下面不调用
  private

  def render_a_content(options={})
    content = []
    icon = options.delete(:icon)
    content << render_icon(icon) unless icon.blank?
    content << options[:value]
    content.join(' ')
  end

  def render_li_options(options={})
    tag_options = {}
    class_str = []
    #render class using options

    class_str << 'disabled' if options[:disabled]
    class_str << 'active' if options.delete(:active)

    align = options.delete(:align)
    class_str << render_align(align) unless (align.blank? || align == 'default')
    class_str << options.delete(:ext_class)

    tag_options[:class] = 'action-link ' + class_str.join(' ')
    tag_options
  end

  def render_a_options(options={})
    tag_options = {}

    #render id
    if options[:name] && options[:id].blank?
      id = sanitize_to_id(options[:name])
      tag_options[:id] = id
    end

    if options[:url]
      tag_options['href'.to_sym] = options.delete(:url)
      tag_options['data-method'.to_sym] = options.delete('url_method'.to_sym) if options['url_method'.to_sym]
      tag_options['data-method'.to_sym] = options.delete('method'.to_sym) if options['method'.to_sym]
    else
      tag_options['data-js'.to_sym] = options.delete(:js)
    end
    tag_options['data-confirm'.to_sym] = options.delete(:confirm)
    #delete  icon
    #translate other options to tag
    tag_options.merge(options.delete_if { |k, v| REMOVED_OPTS.include?(k) })
  end

  def render_align(align)
    case align
      when 'left'
        'pull-left'
      when 'right'
        'pull-right'
    end
  end
end