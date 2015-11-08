#coding: utf-8
module Bootstrap3::TableHelper
  extend ActiveSupport::Concern

  # 显示标准table
  # headers: 表头，数组[[{w: 1, t: 'xxx', colspan: 2, class: 'sss'}, {w: 2, t: 'yyy', rowspan: 2}], [{w: 1, t: 'yyy'}, {w: 1, t: 'zzz'}]]，
  #          w是宽度，符合bootstrap 12列定义规范，t是表头的名称 ，options是任何th可以接受的options，如果有数组中有多个元素，则显示多个表头行
  #          如果show_seq = false，则加起来为12列，否则加起来11列即可，序号列自动给出
  # options: Hash
  #   caption: 表的标题
  #   show_seq: true, false
  #   obj: 需要分页的集合，如果传入则自动分页
  #   cust_row: true, false 是否不根据obj自动生成行，默认是false
  #   no_page: true, false 默认false
  #   fixed: true, false 默认false
  #   class: table-bordered?
  #
  #   parent_obj: 动态行父对象
  #   index: 动态行hidden field 名称
  #   index_name: 动态行hidden field 名称
  #   parent_obj_name: 动态行hidden field 名称
  #
  #   new_row: 新增一行对应的ajax url
  #   actions: 数组，对于表格操作的按钮集合 [{js: link, value: xxxx, icon: zzz}, {js: link2, value: yyyy}] bs_button能用的参数，这里都能用
  #   search: 一个search form，在所有按钮之前 ， 也可以是任意一段html
  #
  #   pagi_param_name: 分页参数的名称
  #   pagi_params: 分页附加参数
  #   pagi_method: get, post
  #   pagi_form: must be provided when post
  #   add_value: new_row的value
  # block: 表的内容
  def table(headers, options={}, &block)
    default_options = {obj: nil, pagi_param_name: nil, pagi_params: nil, caption: nil, show_seq: true}
    opts = default_options.merge(options)
    ext_class = opts.delete(:class) || ''
    fixed = opts.delete(:fixed)
    ext_class += ' table-striped ' if fixed

    caption = opts.delete(:caption)
    show_seq = opts.delete(:show_seq)

    obj = opts.delete(:obj)
    no_page = opts.delete(:no_page)
    cust_row = opts.delete(:cust_row)
    pagi_param_name = opts.delete(:pagi_param_name)
    pagi_params = opts.delete(:pagi_params)
    pagi_method = opts.delete(:pagi_method) || 'get'
    pagi_form = opts.delete(:pagi_form)

    parent_obj = opts.delete(:parent_obj)
    dynamic_opts = {}
    dynamic_opts[:index] = opts.delete(:index) || 0
    dynamic_opts[:index_name] = opts.delete(:index_name) || ''
    dynamic_opts[:parent_obj_name] = opts.delete(:parent_obj_name) || ActiveModel::Naming.param_key(parent_obj) if parent_obj

    new_row = opts.delete(:new_row)
    add_value = opts.delete(:add_value)
    actions = opts.delete(:actions)
    search = opts.delete(:search)

    content_tag('table', nil, {class: 'table table-hover table-bordered '+ext_class}.merge(opts)) do
      content = ''
      # render caption
      # 标题文字， 添加另一行， 各种按钮， 搜索form都会显示在caption标签下
      if caption || new_row || actions || search
        caption ||= '&nbsp;'

        content << content_tag('caption', nil, ({class: 'control-tr'} if new_row || actions || search)) do
          caption_content = ''
          if search
            caption_content << search
          end

          if new_row || actions
            caption_content << handle_actions(opts[:id]||'',
                                              dynamic_opts[:parent_obj_name],
                                              dynamic_opts[:index],
                                              dynamic_opts[:index_name],
                                              new_row,
                                              add_value,
                                              actions)


          end

          raw content_tag('div', raw(caption), class: 'caption-bar') +
              content_tag('div', caption_content.html_safe, class: 'pull-left action-bar')

        end
      end

      # if header is null, then raise error
      headers_count = []
      if headers.nil? && !show_seq
        raise 'Error!  No Table Header! '
      else
        # if 2 or more rows of header
        if headers.size > 0 && headers[0].is_a?(Array)
          first_header = headers.shift
          first_header.unshift({w: 1, t: '序号'}) if show_seq
          headers.unshift(first_header)

          headers.each do |header|
            if headers.index(header) == 0
              content << render_table_header(header, headers_count)
            else
              content << render_table_header(header)
            end
          end

        elsif headers[0].is_a?(Hash)
          headers.unshift({w: 1, t: '序号'}) if show_seq
          content << render_table_header(headers, headers_count)
        end
      end

      # render table content
      # 只要有动态增加行的设置，就会自动产生一个hidden_field记录行数， 命名规则符合 dynamic_hidden_count_name方法
      # 如果是动态增加行
      if obj && parent_obj && !cust_row
        content << collection_dynamic_tr(obj, dynamic_opts, &block)
      # 如果是固定行
      elsif obj && !cust_row
        if obj.empty?
          content << no_data_tr
        else
          obj_index = 0
          obj.each do |o|
            content << capture(o, obj_index, &block) if block
            obj_index += 1
          end
        end
      # 全自定义行
      else
        # 如果全自定义行也有动态增加内容
        if new_row
          content << generate_dynamic_hidden_field(obj, dynamic_opts)
        end
        content << capture(&block).to_s if block
      end

      # render pagination
      if obj && !no_page && obj.respond_to?('total_pages') && obj.total_pages > 1
        #根据headers_count 计算colspan
        colspan = headers_count.map{|c| c.to_i}.sum
        content << paginate_tr(colspan, obj, pagi_param_name, pagi_params, pagi_method, pagi_form)
      end
      raw content
    end
  end

  #显示表格内容，按行显示
  #content: Array，行内容， 每一个元素是一个Hash， 如果有css，必须在第一个元素格式为 css:xxxxx， 其他元素 l:xxx，靠左对齐， c:xxx，居中对齐, r:yyy，靠右对齐， 其他属性如colspan: 2 照样写
  def table_tr(*content)

    if content[0].has_key?(:css)
      tr_class = content.shift[:css]
    else
      tr_class = ''
    end

    content_tag('tr', nil, class: tr_class) do
      tds = ''
      content.each do |c|
        col = c.dup
        align = ''
        align_key = col.keys.first.to_s
        value = col.delete(col.keys.first)
        ext_class = col.delete(:class) || ''
        case align_key
          when 'c'
            align = 'text-center '
          when 'r'
            align = 'text-right '
        end
        tds << content_tag('td', value, {class: align + ext_class}.merge(col))
      end
      raw tds
    end
  end

  #含有控件的表格内容，按行显示
  #参考 table_tr
  #没有控件的td，请加样式 no-control，否则行高不对
  def control_table_tr(*content)
    if content[0].has_key?(:css)
      tr_class = content.shift[:css]
    else
      tr_class = ''
    end
    table_tr({css: "control-tr #{tr_class}"}, *content)
  end

  def no_data_tr
    content_tag('tr',class:'no-data') do
      content_tag('td', '无数据', colspan: 99, class: 'tc')
    end
  end

  #生成动态行计数器的名称，没啥解释的
  # parent_obj_name: 可以是一个对象，也可以是一个名称，对象会自动转为名称
  # 当你的页面有多个table都可以动态添加行，并且parent_obj_name一样的话，传下面两个参数的任何一个都可以帮你区别最后的名称
  # index:
  # index_name:
  def dynamic_hidden_count_name(parent_obj_name, index=0, index_name='')
    if parent_obj_name.is_a? String
      name = parent_obj_name
    elsif parent_obj_name.class.respond_to?('model_name')
      name = ActiveModel::Naming.param_key(parent_obj_name)
    else
      name = parent_obj_name.to_s
    end

    [name, index, index_name, 'count'].join('_')
  end

  protected
  #######################################
  # 下面的就不要直接用了

  #分页显示行
  #colspan: 不说了
  #collection: 分页的对象
  #param_name: page参数的名称，默认为page
  #p: 附加参数
  def paginate_tr(colspan, collection, param_name=nil, p=nil, method='get', form=nil)
    content_tag(:tr) do
      content_tag(:td, nil, :colspan => colspan) do
        params = {class: 'pagination m0a pagination-centered'}
        params[:param_name] = param_name if param_name
        params[:params] = p
        if method != 'get'
          params[:form] = form
          post_will_paginate(collection, params)
        else
          will_paginate(collection, params)
        end

      end
    end
  end

  #动态增加行
  #将给模版带入2个参数， obj 和 当前obj在collection中的位置
  # parent_obj: 父对象
  # collection: 当前集合
  # options:
  #   index:
  #   index_name:
  #   parent_obj_name:
  #
  def collection_dynamic_tr(collection, options={}, &block)
    #cal hidden field name
    output = generate_dynamic_hidden_field(collection, options)

    obj_index = 0
    collection.each do |o|
      output << raw(capture(o, obj_index, &block)) if block
      obj_index += 1
    end

    raw output
  end

  def generate_dynamic_hidden_field(collection, options={})
    if collection.respond_to?('size')
      size = options[:index].to_i == 0 ? collection.size : (options[:index].to_i + collection.size)
    else
      size = options[:index].to_i == 0 ? 0 : options[:index].to_i
    end

    hidden_field_tag(dynamic_hidden_count_name(options[:parent_obj_name], options[:index], options[:index_name]), size)
  end

  def handle_actions(table_id, parent_obj_name, index, index_name, new_row,add_value, actions)
    full_actions = []
    if new_row
      js = "$.jq_remote_get('#{new_row}',
            {index: $('##{dynamic_hidden_count_name(parent_obj_name, index, index_name)}').val(),
             index_name: '#{index_name}',
             index_offset: #{index.to_i}})"
      full_actions << {js: js, value: add_value.blank? ? '新增另一行' : add_value, icon: 'plus_sign'}
    end

    full_actions << actions if actions
    btn_group do
      btn_index = 0
      btns = ''
      full_actions.flatten.each do |a|
        css = (a.delete(:css).blank? ? 'btn-primary btn-sm' : a.delete(:css))
        btns << bs_button_js_to(a.delete(:js), a.delete(:value), css,'fa fa-plus')
        btn_index += 1
      end
      raw btns
    end
  end

  private
  def render_table_header(headers, columns=[])
    content_tag('thead') do
      content_tag('tr') do
        th_content = ''
        headers.each do |h|
          if h.has_key?(:l)
            align_class = 'text-left'
            title = h.delete(:l)
          elsif h.has_key?(:r)
            align_class = 'text-right'
            title = h.delete(:r)
          else
            align_class = 'text-center'
            title = h.delete(:t)
          end

          width = h.delete(:w)
          ext_class = h.delete(:class) || ''
          columns << (h[:colspan] || 1)

          th_content << content_tag('th', title, {class: "#{align_class} col-sm-#{width} #{ext_class}"}.merge(h))
        end
        raw th_content
      end
    end

  end

end