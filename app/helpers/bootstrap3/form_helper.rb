#coding: utf-8

module Bootstrap3::FormHelper
  extend ActiveSupport::Concern

  #基础form builder， 不要直接用
  class FormBuilderBase < ActionView::Helpers::FormBuilder
    DEFAULT_EXT_FIELD_HELPERS = ['select', 'collection_select', 'grouped_collection_select', 'time_zone_select',
                                 'date_select', 'time_select', 'datetime_select', 'cktext_area',
                                 'checkboxes', 'radios', 'multiselect', 'autocomplete',
                                 'action_input', 'multiselect_list', 'fcbk_autocomplete',
                                 'fcbk_multiselect', 'datepicker', 'timepicker', 'datetimepicker', 'yes_no']

    class_attribute :ext_field_helpers, :inited

    def initialize(object_name, object, template, options, proc=nil)
      super(object_name, object, template, options)

      #如果是正式环境，只初始化一次，其他免谈
      if Rails.env != 'production' || !FormBuilderBase.inited
        FormBuilderBase.ext_field_helpers ||= []
        FormBuilderBase.ext_field_helpers.concat FormBuilderBase::DEFAULT_EXT_FIELD_HELPERS
        FormBuilderBase.ext_field_helpers.concat field_helpers.map(&:to_s) - %w(label radio_button fields_for)
        FormBuilderBase.ext_field_helpers.uniq!

        FormBuilderBase.inited= true
      end
    end

    def hidden_area(&proc)
      @template.content_tag('div', nil, class: 'hide') do
        @template.capture(&proc) if proc
      end
    end

    def tag_id(method)
      sanitized_object_name ||= @object_name.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")
      sanitized_method_name ||= method.sub(/\?$/, "")

      "#{sanitized_object_name}_#{sanitized_method_name}"
    end

    ##########################################
    # ext plugin
    ##########################################

    # from bootstrap_yes_no_helper.rb
    def yes_no(method, options={})
      @template.yes_no(@object_name, method, objectify_options(options))
    end

    #自动完成
    # from bootstrap_autocomple_helper.rb
    def autocomplete(method, options={})
      js_options = options.delete(:js_options) || {}
      @template.autocomplete(@object_name, method, objectify_options(options), js_options)
    end

    #带按钮的input
    # from bootstrap_actioninput_helper.rb
    #options加了几个参数
    #  js_options:
    #    name: 按钮name, 必须
    #    icon: 图标
    #    value: 按钮文本
    #    position: 按钮位置 , before, after 默认after
    #    click: 按钮执行js
    def action_input(method, options={})
      js_options = options[:js_options] || {}
      @template.action_input(@object_name, method, objectify_options(options), js_options)
    end

    # from bootstrap_datetime_helper.rb
    def datepicker(method, options={})
      js_options = options.delete(:js_options) || {}
      @template.datepicker(@object_name, method, objectify_options(options), js_options)
    end

    # from bootstrap_datetime_helper.rb
    def timepicker(method, options={})
      js_options = options.delete(:js_options) || {}
      @template.timepicker(@object_name, method, objectify_options(options), js_options)
    end

    # from bootstrap_datetime_helper.rb
    def datetimepicker(method, options={})
      date_options = options.delete(:date_options) || {}
      time_options = options.delete(:time_options) || {}
      @template.datetimepicker(@object_name, method, objectify_options(options), date_options, time_options)
    end

    # checkbox group
    # from bootstrap_checkbox_helper.rb
    def checkboxes(method, choices, options={})
      @template.checkboxes(@object_name, method, choices, objectify_options(options))
    end

    # radio button group
    # from bootstrap_radio_helper.rb
    def radios(method, choices, options={})
      @template.radios(@object_name, method, choices, objectify_options(options))
    end

    # 弹出多选
    # from bootstrap_multiselect_helper.rb
    def multiselect(method, options={})
      js_options = options.delete(:js_options)||{}
      #select 是隐藏的，将class转移到button上
      js_options[:class] = options[:class]
      if options[:placeholder]
        js_options[:none_selected_text] = "请选择#{options[:placeholder]}"
      end
      @template.multiselect(@object_name, method, options.delete(:choices), objectify_options(options), js_options)
    end

    # 多选列表
    # from bootstrap_multiselect_helper.rb
    def multiselect_list(method, options={})
      js_options = options.delete(:js_options)||{}
      js_options[:class] = options.delete(:class)
      @template.multiselect_list(@object_name, method, options.delete(:choices), objectify_options(options), js_options)
    end

    # facebook样式的自动完成， 未实现
    def fcbk_autocomplete(method, options={})

    end

    # facebook样式的多选， 未实现
    def fcbk_multiselect(method, options={})

    end

    # 扩展check_box， 允许实现 readonly= true
    def check_box(method, options={})
      if options[:readonly]
        options[:onclick] = 'this.checked=!this.checked'
      end

      checked_value = options.delete(:checked_value) || '1'
      unchecked_value = options.delete(:unchecked_value) || '0'

      super(method, options, checked_value, unchecked_value)
    end

    #options 各种rails view helper的都收
    #前面的参数和rails view helper传的一样就行
    #另外在最后一个参数hash中加了
    #  readonly_when_edit: 编辑的时候不让修改
    def control(type, label, *args)
      if FormBuilderBase.ext_field_helpers.include? type
        render_control(type, label, *args)
      elsif FormBuilderBase.ext_field_helpers.include? "#{type}_field"
        render_control("#{type}_field", label, *args)
      else
        raise 'Error! Unknown Control Type. Check your code!'
      end
    end

    protected
    def render_control(type, label, *args)
      options = args.extract_options!

      #readonly 优先
      unless options.has_key?(:readonly)
        # 如果对象不是新建
        readonly = options.delete(:readonly_when_edit)
        if readonly && !@object.new_record?
          options[:readonly] = true
        end
      end
      self.__send__(type, *(args << options))
    end

  end

  # 带有布局模版的form， 一般用这个
  class LayoutFormBuilder < FormBuilderBase

    include Bootstrap3::BootstrapHelper::Layout

    def initialize(object_name, object, template, options, proc=nil)
      self.max_columns= options[:html][:max_columns] if options[:html]
      self.max_spans = options[:html][:max_spans] if options[:html]
      self.max_spans ||= 12
      super(object_name, object, template, options, proc)
    end

    def fields_for(record_name, record_object = nil, fields_options = {}, &block)
      fields_options[:html] ||= DEFAULT_LAYOUT_FORM_HTML_OPTIONS
      super(record_name, record_object, fields_options, &block)
    end

    #产生一行
    #layout: 布局 '1', '1:1', '1:1:1', '1:2', '2:1' <---这是比例
    def row(layout='1', &proc)
      _row(layout)

      @template.content_tag('div', nil, class: 'form-group') do
        @template.capture(&proc) if proc
      end
    end

    #调用了controls就不能再调用control
    #调用controls说明你想自定义control的内容，请调用基本的helper，控件大小也请自己算好
    #label: 标题
    #method: 标题对应的method deprecated!
    def controls(label, method=nil, &proc)
      label_span = _label_span(_fetch_seq)
      value_span = _value_span(self.seq-1)
      div = @template.content_tag('label', label, class: "control-label col-sm-#{label_span}")
      #self.label(method, label, class: "control-label span#{label_span}")

      div << @template.content_tag('div', nil, class: "col-sm-#{value_span}") do
        #@template.content_tag('div') do
        #  @template.capture(&proc) if proc
        #end
        @template.capture(&proc) if proc
      end
      @template.raw div
    end

    protected
    def render_control(type, label, *args)
      method = args[0]
      options = args.extract_options!

      #readonly 优先
      unless options.has_key?(:readonly)
        # 如果对象不是新建
        readonly = options.delete(:readonly_when_edit)
        if readonly && !@object.new_record?
          options[:readonly] = true
        end
      end

      self.controls(label, method) do
        case type
          when 'check_box' , 'radios'
            self.__send__(type, *(args << options))
          when 'select'
            #如果参数里还有3个： method, choice, {} ，则表示 options为html_options
            if args.size == 3
              new_class = options.delete(:class) || ''
              new_class += " form-control"
              self.__send__(type, *(args << options.merge(:class => new_class)))
              #如果参数里还有2个： method, choice，则表示没有html_options，自己加一个
            elsif args.size == 2
              args << options
              args << {:class => "form-control"}
              self.__send__(type, *args)
              #报错
            else
              raise 'Error Parameter of Select'
            end
          else
            new_class = options.delete(:class) || ''
            new_class += " form-control"
            self.__send__(type, *(args << options.merge(:class => new_class)))
        end

      end
    end

  end

  # 简单搜索form
  class SimpleSearchFormBuilder < FormBuilderBase

    protected
    def render_control(type, label, *args)
      options = args.extract_options!

      #默认小控件
      options[:class] = options[:class] ? options[:class] + ' form-control' : 'form-control'

      #readonly 优先
      unless options.has_key?(:readonly)
        # 在simple search中，无论对象是不是新建，只要有readonly属性，都设为只读
        readonly = options.delete(:readonly_when_edit)
        if readonly
          options[:readonly] = true
        end
      end

      #如果label外置，则将label放到控件的左边
      if options.delete(:ph_out)
        @template.content_tag('label') do
          @template.raw (label + ' ' + self.__send__(type, *(args << options)))
        end
      else
        options[:placeholder] = label
        self.__send__(type, *(args << options))
      end

    end
  end

  # 高级搜索form，未实现
  class AdvSearchFormBuilder < LayoutFormBuilder

  end

  DEFAULT_FORM_BASE_OPTIONS = {builder: Bootstrap3::FormHelper::FormBuilderBase}
  DEFAULT_LAYOUT_FORM_HTML_OPTIONS = {class: 'form-horizontal form-base', max_columns: 2}
  DEFAULT_LAYOUT_FORM_OPTIONS = {builder: Bootstrap3::FormHelper::LayoutFormBuilder}
  DEFAULT_SIMPLE_SEARCH_FORM_OPTIONS = {builder: Bootstrap3::FormHelper::SimpleSearchFormBuilder}
  DEFAULT_SIMPLE_SEARCH_FORM_HTML_OPTIONS = {method: 'get'}
  DEFAULT_ADV_SEARCH_FORM_OPTIONS = {builder: Bootstrap3::FormHelper::AdvSearchFormBuilder}
  DEFAULT_ADV_SEARCH_FORM_HTML_OPTIONS = {class: 'form-horizontal form-base form-adv-search', method: 'get', max_columns: 2}
  #替换rails自带的form_for， 参数和原来一致
  # options中加入新参数
  #  classic: true, false ，默认为false，如果设为true，则使用rails自带的form_for
  #  html:
  #    max_columns: 2
  #    max_span: 12
  #  nav: position: 当前位置，字符串
  #       return_url: 返回按钮url
  #       no_save: true, false 不显示保存按钮，默认false
  #       sec_save: true, false 保存按钮不作为主按钮，默认false
  #       btn_bar: 自定义按钮区域，会自动加在save和return的前面
  #  如果使用nav参数，则会产生一个默认的导航栏，只有保存和返回2个按钮，请自便
  def form_for(record, options = {}, &proc)
    #判断是否是经典模式form_for，如果是的话直接用rails自带的
    if !options.delete(:classic)

      # 重新组装 html 参数
      if options[:html]
        html_options = Bootstrap3::FormHelper::DEFAULT_LAYOUT_FORM_HTML_OPTIONS.merge(options.delete(:html))
      else
        html_options = Bootstrap3::FormHelper::DEFAULT_LAYOUT_FORM_HTML_OPTIONS.dup
      end

      # 收集导航参数
      nav = options.delete(:nav)

      opts = Bootstrap3::FormHelper::DEFAULT_LAYOUT_FORM_OPTIONS.merge(options)
      opts[:html] = html_options

      #在form中加入导航，错误信息提示等自定义元素
      new_proc = Proc.new { |f|
        form_content = ''
        #<%= button_div do %>
        #            <%= bs_save %>
        #            <%#= f.button '关闭', class: "btn btn-group-lg btn-white", type: 'button', onclick: 'parent.layer.close(parent.MAIN_LAYER_WINDOW);' %>
        #            <%= bs_button_js('parent.layer.close(parent.MAIN_LAYER_WINDOW);', '关闭', "btn btn-group-lg btn-white",'fa fa-times') %>
        #        <% end %>
        if nav
          form_content << button_div do
            buttons = []
            buttons << nav[:btn_bar] if nav[:btn_bar]
            buttons << bs_save
            buttons << bs_close
            #buttons << bs_button_js('parent.layer.close(parent.MAIN_LAYER_WINDOW);', '关闭', "btn btn-group-lg btn-white",'fa fa-times')
            raw buttons.join(' ')
          end
        end
        form_content << errors_for(record).html_safe
        form_content << capture(f, &proc) if proc
        raw form_content
      }

      # 显示form  封装的div放在form layout里处理，不再为show页面单独定义div
      #puts opts.inspect
      #content_tag('div', nil, class: 'ibox float-e-margins') do
      #  content_tag('div', nil,class: "ibox-content") do
          super(record, opts, &new_proc)
      #  end
      #end


    else
      content_tag('div', nil, class: 'ibox float-e-margins') do
        content_tag('div', nil,class: "ibox-content") do
          super(record, options, &proc)
        end
      end
    end
  end

  # 在局部模版中，不方便使用form_for，又想使用 fields_for的时候有各种控件可用，先调用这个
  # 和fields_for参数一样， 只是默认会带有各种控件
  def base_fields_for(record_name, record_object = nil, options = {}, &block)
    fields_for(record_name, record_object, DEFAULT_FORM_BASE_OPTIONS.merge(options), &block).html_safe
  end

  def layout_fields_for(record_name, record_object = nil, options = {}, &block)
    fields_for(record_name, record_object, DEFAULT_LAYOUT_FORM_OPTIONS.merge(options), &block).html_safe
  end

  #search form helper %%% OVERRIDE RANSACK %%%
  #用来构建 search form 一类的form
  #obj: form对应的对象，Ransack::Search
  #options:
  #  html:
  #    method: get, post, put， 默认get
  #    class: ..
  #  nav_bar: true, false 默认false
  #  object_name: 对象名
  #  url: 查询的url
  #  adv_url: 高级查询url
  #  btn_bar: 除查询外的其他按钮
  #例如:
  #  search_form_for(obj, url:url_for(:controller=>'test', :action=>'xxx'), html: {method:post}) do |f|
  #    f.control('text', 'label', 'method_name', ph_out: true)
  #  end
  def search_form_for(obj, options, &proc)
    # 重新组装 html 参数
    opts = Bootstrap3::FormHelper::DEFAULT_SIMPLE_SEARCH_FORM_OPTIONS.merge(options)
    if obj.is_a?(Ransack::Search)
      search = obj
      url = opts.delete(:url) || polymorphic_path(obj.klass)
    elsif obj.is_a?(Array) && (search = obj.detect { |o| o.is_a?(Ransack::Search) })
      url = opts.delete(:url) || polymorphic_path(obj.map { |o| o.is_a?(Ransack::Search) ? o.klass : o })
    elsif obj.is_a?(FullSearch::Criteria)
      search = obj
      url = opts.delete(:url) || request.path
    else
      raise ArgumentError, 'No Ransack::Search or FullSearch::Criteria object  was provided to search_form_for!'
    end
    fields_opts = {}
    #method = opts.delete(:method)

    object_name = opts.delete(:object_name) || 'q'
    builder = opts.delete(:builder)
    adv_url = opts.delete(:adv_url)
    btn_bar = opts.delete(:btn_bar)
    nav_bar = opts.delete(:nav_bar)
    html_options = opts.delete(:html) || {}

    if nav_bar
      class_str = 'form-inline navbar-form'
    else
      class_str = 'form-inline form-inline-base'
    end

    if html_options[:class]
      class_str = class_str + ' ' + html_options.delete(:class)
    end
    html_options = DEFAULT_SIMPLE_SEARCH_FORM_HTML_OPTIONS.merge(html_options).merge({class: class_str})

    fields_opts[:parent_builder] = instantiate_builder(object_name, search, {builder: builder}, &proc)
    fields_opts[:builder] = builder



    form_tag(url, html_options) do
      form_content = fields_for(object_name, search, fields_opts, &proc)
      form_content << bs_search
      form_content << ''
      #form_content << bs_button('bn_adv_search', '高级查询', url: adv_url, icon: 'search') if adv_url
      form_content << ' '
      form_content << btn_bar if btn_bar
      form_content.html_safe
    end
  end

  #search form helper
  #用来构建 search form 一类的form
  #obj: form对应的对象，Ransack::Search
  #options:
  #  html:
  #   method: get, post, put， 默认get
  #   class: ..
  #  nav:
  #   position:
  #   btn_bar:
  #  object_name: 对象名
  #  url: 查询的url
  #  adv_url: 高级查询url
  #  btn_bar: 除查询外的其他按钮
  def adv_search_form_for(obj, options,nav_menu, &proc)
    # 重新组装 html 参数
    opts = Bootstrap3::FormHelper::DEFAULT_ADV_SEARCH_FORM_OPTIONS.merge(options)
    if obj.is_a?(Ransack::Search)
      search = obj
      url = opts.delete(:url) || polymorphic_path(obj.klass)
    elsif obj.is_a?(Array) && (search = obj.detect { |o| o.is_a?(Ransack::Search) })
      url = opts.delete(:url) || polymorphic_path(obj.map { |o| o.is_a?(Ransack::Search) ? o.klass : o })
    elsif obj.is_a?(FullSearch::Criteria)
      search = obj
      url = opts.delete(:url) || request.path
    else
      raise ArgumentError, 'No Ransack::Search or FullSearch::Criteria object was provided to adv_search_form_for!'
    end
    fields_opts = {}
    #method = opts.delete(:method)
    nav = opts.delete(:nav)
    object_name = opts.delete(:object_name) || 'q'
    builder = opts.delete(:builder)
    adv_url = opts.delete(:adv_url)
    btn_bar = opts.delete(:btn_bar)
    html_options = opts.delete(:html) || {}

    if html_options[:class]
      class_str = DEFAULT_ADV_SEARCH_FORM_HTML_OPTIONS[:class] + ' ' + html_options.delete(:class)
      html_options = DEFAULT_ADV_SEARCH_FORM_HTML_OPTIONS.merge(html_options).merge({:class => class_str})
    else
      html_options = DEFAULT_ADV_SEARCH_FORM_HTML_OPTIONS.merge(html_options)
    end

    fields_opts[:parent_builder] = instantiate_builder(object_name, search, {builder: builder}, &proc)
    fields_opts[:builder] = builder

    form_tag(url, html_options) do

      form_content = fields_for(object_name, search, fields_opts, &proc)

      if nav
        form_content << nav_bar(nav_menu) do
          buttons = bs_search('pull-right')
          buttons << ''#bs_button('bn_adv_search', '高级查询', url: adv_url, icon: 'search') if adv_url
          buttons << nav[:btn_bar] if nav[:btn_bar]
          buttons.join(' ').html_safe
        end
      else
        form_content << bs_search('pull-right')
        form_content << ' '
        form_content << ' '#bs_button('bn_adv_search', '高级查询', url: adv_url, icon: 'search') if adv_url
        form_content << ' '
        form_content << btn_bar if btn_bar
      end

      form_content.html_safe
    end
  end

  # 相比action_input，图标是嵌入在text框内的， 现在只在日期控件里面用了
  def embed_input(icon, &block)
    content_tag('div', nil, class: 'input-group date') do
      content = capture(&block) if block
      content << content_tag('span', nil, class: "input-group-addon") do
        content_tag('i', nil, class: "fa fa-calendar")
      end
      content.html_safe
    end
  end
end