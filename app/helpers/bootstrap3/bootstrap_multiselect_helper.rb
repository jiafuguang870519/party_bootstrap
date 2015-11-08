#coding: utf-8
module Bootstrap3::BootstrapMultiselectHelper

  class MultiselectTag < ActionView::Helpers::Tags::Select
    attr_accessor :js_options

    def initialize(object_name, method_name, template_object, choices, options={}, js_options={})
      #样式
      html_options = options.delete(:html) || {}
      html_options[:class] ||= "jq_multiselect #{options.delete(:class)}"
      html_options[:multiple] = true

      self.js_options = js_options

      super(object_name, method_name, template_object, choices, options, html_options)
    end

    def render
      output = super
      add_default_name_and_id(@html_options)
      width = @html_options[:width] || '100%'
      output << @template_object.generate_multiselect_js(@html_options['id'], js_options,width)
    end
  end

  class MultiselectListTag < ActionView::Helpers::Tags::Select
      attr_accessor :js_options

      def initialize(object_name, method_name, template_object, choices, options={}, js_options={})
        #样式
        html_options = options.delete(:html) || {}
        #html_options[:class] ||= 'jq_multiselect_list'
        html_options[:multiple] = true

        self.js_options = js_options

        super(object_name, method_name, template_object, choices, options, html_options)
      end

      def render
        output = super
        add_default_name_and_id(@html_options)

        output << @template_object.generate_multiselect_list_js(@html_options['id'], js_options)
      end
    end

  module FormHelper
    def multiselect(object, method, choices, options={}, js_options={})
      Bootstrap3::BootstrapMultiselectHelper::MultiselectTag.new(object, method, self, choices, options, js_options).render
    end

    def multiselect_list(object, method, choices, options={}, js_options={})
      Bootstrap3::BootstrapMultiselectHelper::MultiselectListTag.new(object, method, self, choices, options, js_options).render
    end

  end

  module FormTagHelper
    #多选list
    def multiselect_tag(name, option_tags = nil, options={}, js_options={})
      #多选
      options[:multiple] = true
      options[:class] = options[:class] || 'jq_multiselect'
      select_tag(name, option_tags, options) + generate_multiselect_js(sanitize_to_id(name), js_options)
    end

    #多选list
    def multiselect_list_tag(name, option_tags = nil, options={}, js_options={})
      #多选
      options[:multiple] = true
      #样式
      options[:class] = options[:class] || 'jq_multiselect_list'
      select_tag(name, option_tags, options) + generate_multiselect_list_js(sanitize_to_id(name), js_options)
    end
  end

  def generate_multiselect_list_js(obj_id, options={})
    height = options[:height] || 150

    script = ''
    script << "$(document).ready(function () {"
    script << "   $('##{obj_id}').css('height', #{height});"
    script << "   $('##{obj_id}').multiselect_list({dividerLocation:0.5});"
    script << "});"
    javascript_tag(script)
  end

  def generate_multiselect_js(obj_id, options={},width)
    #selected_list = options[:selected_list] || "4"
    script = ''
    script << "$(function () {"

    # Bigxiang 2012.12.25
    # When I use select with multiple = true, It always put a "" in result, the reason is an input...
    # I don't know why multiselect renders an input in rails 3.2+..... I disabled it
    script << "  $('input[name=\"'+ $('##{obj_id}').attr('name') +'\"]').attr('disabled', 'disabled'); "
    script << "  var #{obj_id} = $('##{obj_id}').multiselect({"
    #script << "     selectedList: #{selected_list}, classes: 'bs_multiselect_btn #{options[:class]}', "
    #
    #if options[:js_selected_text] || options[:selected_text]
    #  script << "   selectedText: '#{options[:js_selected_text]||options[:selected_text]}',"
    #end
    #if options[:none_selected_text]
    #  script << "   noneSelectedText: '#{options[:none_selected_text]}',"
    #end
    #script << "nSelectedText: '  已选择!',"
    #script << "numberDisplayed: 4,"
    script << "     buttonWidth: '#{width}',"
    script << "maxHeight: 200,"
    #script << "includeSelectAllOption: true,"   #全选按钮
    #script << "allSelectedText: '已全选！',"     #全部选择后显示
    #script << "selectAllText: '全选',"           #全选文字
    #script << "enableFiltering: true,"           #查询
    #script << "nonSelectedText: '请选择',"   #初始化显示“请选择”
    #script << "filterPlaceholder: '输入关键字...',"    #查询内容
    #script << "enableClickableOptGroups: true,"  #按组选择

    #script << "     header: #{options[:header]||'true'}"
    script << "   });"
    script << "});"
    
    javascript_tag(script)
  end
end

ActionView::Helpers::FormHelper.send(:include, Bootstrap3::BootstrapMultiselectHelper::FormHelper)
ActionView::Helpers::FormTagHelper.send(:include, Bootstrap3::BootstrapMultiselectHelper::FormTagHelper)