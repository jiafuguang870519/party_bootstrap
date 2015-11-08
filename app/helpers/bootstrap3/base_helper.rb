module Bootstrap3::BaseHelper

  # Typography
  # Headings 未实现

  # Lead
  # 突出显示一个p内的文字
  # text:
  # options: 所有p能接受的options
  # block: 嵌套
  def p_lead(text, options={}, &block)
    content_tag('p', nil, merge_predef_class('lead', options)) do
      raw text + (capture(&block) if block)
    end
  end

  # Small 未实现
  # Bold 未实现
  # Italics 未实现
  # muted, text-warning, text-error, text-info, text-success 未实现
  # Abbreviations 未实现
  # Addresses 未实现
  # Blockquotes 未实现

  # Lists
  ##############################################################################

  # bootstrap Typography List
  # collction 支持嵌套数组
  # options:
  #   type: unordered, ordered, unstyled, 默认unordered
  #   use_parent_opts: true, false 默认为true
  #   block_position: before, after 默认为after
  #   li_option: li 的 option
  def list(collection, options={}, &block)
    opts = options.dup

    type = opts.delete(:type) || 'unordered'
    tag = (type == 'ordered') ? 'ol' : 'ul'
    unstyled_class = (type == 'unstyled') ? 'unstyled ' : ''
    ext_class = opts.delete(:class) || ''
    li_option = opts.delete(:li_option) || {}
    position = opts.delete(:block_position) || 'after'
    use_parent_opts = opts.delete(:use_parent_opts) || true

    content_tag(tag, nil, {class: unstyled_class + ext_class}.merge(opts)) do
      ul_content = ''

      ul_content << capture(&block) if block && position == 'before'

      collection.each do |obj|
        if obj.is_a? Array
          ul_content << content_tag('li', obj.to_s, li_option) do
            list(obj, (use_parent_opts ? options : {}), &block)
          end
        else
          ul_content << content_tag('li', obj.to_s, li_option)
        end
      end

      ul_content << capture(&block) if block && position == 'after'

      raw ul_content
    end
  end

  # Inline 未实现
  # Description 未实现

  # Code
  # 未实现

  # Tables
  # 参见 Bootstrap_table_helper.rb

  # Forms
  # 参见 Bootstrap_form_helper.rb

  # Buttons
  # 参见 bootstrap_button_helper.rb

  # Images
  # 圆角图片
  # 和 image_tag 一样用
  def r_image_tag(source, options={})
    image_tag(source, merge_predef_class('img-rounded', options))
  end

  # 圆形图片
  # 和 image_tag 一样用
  def c_image_tag(source, options={})
    image_tag(source, merge_predef_class('img-circle', options))
  end

  # 带边框图片
  # 和 image_tag 一样用
  def p_image_tag(source, options={})
    image_tag(source, merge_predef_class('img-polaroid', options))
  end

  # Icons by Glyphicons
  # 显示按钮图标，用twitter-bootstrap-rails的gem实现
  # icon: 中间带 '-' 的可以用 '_' 替代
  def render_icon(icon)
    glyph(icon)
  end

  def glyph(*names)
    content_tag :i, nil, :class => names.map{|name| "icon-#{name.to_s.gsub('_','-')}" }
  end
end