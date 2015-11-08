#coding: utf-8
module Bootstrap3::ShowHelper
  extend ActiveSupport::Concern
  include ActionView::Helpers::FormHelper

  class ShowBuilder
    attr_accessor :object_name, :object

    include Bootstrap3::BootstrapHelper::Layout

    def initialize(object_name, object, template, options, &block)
      @object_name, @object, @template, @proc = object_name, object, template, block
      self.max_columns= options.delete(:max_columns)
      self.max_spans = options.delete(:max_spans)
    end

    def to_s
      @template.content_tag('form', nil, class: 'form-horizontal m-t',novalidate:"novalidate") do
        @template.capture(self, &@proc)
      end
    end

    #显示一行，定义layout
    #'1', '1:1', '1:1:1', '1:2', "2:1", "1:3", "3:1" 等等，能被12整除就可以
    def row(layout='1', &block)
      _row(layout)

      @template.content_tag('div', nil, class: 'form-group') do
        @template.capture(&block) if block
      end
    end

    #显示通过对象方法得到的只读内容
    #label: 标签
    #method: 要显示的方法
    #before_method: 如果有自定义的内容，是否放在对象方法返回值之前
    def show_method(label, method, options={}, before_method=false, &block)
      current_seq = _fetch_seq
      opts = options.dup
      opts[:before_method] = true if before_method
      opts[:label_span] = opts.has_key?(:label_span)? opts.fetch(:label_span) : _label_span(current_seq)
      opts[:value_span] = opts.has_key?(:value_span)? opts.fetch(:value_span) : _value_span(current_seq)

      @template.show_method(label, @object, method, opts, &block)
    end

    #显示一个自定义的只读内容
    #label: 标签
    def show_content(label, options={}, &block)
      current_seq = _fetch_seq
      opts = options.dup
      opts[:label_span] = opts.has_key?(:label_span)? opts.fetch(:label_span) : _label_span(current_seq)
      opts[:value_span] = opts.has_key?(:value_span)? opts.fetch(:value_span) : _value_span(current_seq)

      @template.show_content(label, opts, &block)
    end

  end

  #显示一个表单样式的只读页面
  #要显示的对象
  def form_show(object, options={}, &block)
    raise 'Missing Block' unless block_given?

    options[:max_columns] = 2 unless options[:max_columns]
    options[:max_spans] = 12 unless options[:max_spans]

    if !object.class.respond_to?('model_name')
      raise 'It must be a class that extend ActiveModel::Naming or be an ActiveRecord::Base'
    else
      object = object.is_a?(Array) ? object.last : object
      object_name = ActiveModel::Naming.param_key(object)
    end
    ShowBuilder.new(object_name, object, self, options, &block)
  end

  #显示通过对象方法得到的只读内容
  #label: 标签
  #object: 要显示的对象
  #method: 要显示的方法
  #options:
  #  label_span: 标签宽度
  #  value_span: 内容宽度
  #  before_method: 如果有自定义的内容，是否放在对象方法返回值之前
  def show_method(label, object, method, options={}, &block)
    p '3333333333333333333333333333'
    p options
    label_span = options.delete(:label_span)
    value_span = options.delete(:value_span)
    before = options.delete(:before_method)
    ext_class = options.delete(:class) || ''
    text = content_tag('label', label, class: "col-sm-#{label_span} text-right")
    text << content_tag('div', nil, {class: "col-sm-#{value_span}"}.merge(options)) do
      block_content = (capture(&block) if block) || ''
      value = ((method && object.respond_to?(method)) ? object.send(method) : '') || ''

      before ? block_content << value.to_s : value.to_s << block_content
    end
    raw text
  end

  #显示一个自定义的只读内容
  #label: 标签
  #options:
  #  label_span: 标签宽度
  #  value_span: 内容宽度
  def show_content(label, options={}, &block)
    label_span = options.delete(:label_span)
    value_span = options.delete(:value_span)
    ext_class = options.delete(:class) || ''
    text = content_tag('label', label, class: "col-sm-#{label_span} text-right")
    text << content_tag('div', nil, {class: "col-sm-#{value_span}"}.merge(options)) do
      capture(&block) if block
    end
    raw text
  end

end