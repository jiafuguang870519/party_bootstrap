#coding: utf-8
module Bootstrap3::AutocompleteHelper

  DEFAULT_OPTIONS = {autocomplete: 'off'}

  def js_autocomplete_tag(id, js_options={})
    default_js_options = {source: 'autocompleteSource',
                          items: 10, min_length: 1, updater: 'autocompleteUpdater', sorter: 'autocompleteSorter'}

    js_options = default_js_options.merge(js_options)
    javascript_tag do
      raw <<JSCRIPT
        (function() {
          $(document).ready(function(){
            var labels, mapped;

            #{autocomplete_source}
      #{autocomplete_remote_source}
      #{autocomplete_sorter}
      #{autocomplete_updater}

            $('##{id}').typeahead({
              source: #{js_options[:source]},
              items: #{js_options[:items]},
              minLength: #{js_options[:min_length]},
              #{js_options[:matcher] ? 'matcher: ' + js_options[:matcher] + ',' : ''}
              sorter: #{js_options[:sorter]},
              #{js_options[:highlighter] ? 'highlighter: ' + js_options[:highlighter] + ',' : ''}
              updater: #{js_options[:updater]}
            });
          });
        }).call(this);
JSCRIPT
    end
  end

  private
  def autocomplete_source(js_options={})
    raw <<JSCRIPT
      var autocompleteSource = function(query, process) {
        labels = [];
        mapped = {};

        element = $(this)[0].$element;

        $.each(eval(element.data('source')), function (i, item) {
            labels.push(item.label);
            mapped[item.label] = item;
        });

        process(labels);
      };
JSCRIPT
  end

  def autocomplete_remote_source(js_options={})
    raw <<JSCRIPT
      var autocompleteRemoteSource = function(query, process) {
        element = $(this)[0].$element;

        $.get(eval(element.data('remote-source')), {q:query}, function (data) {
            labels = [];
            mapped = {};

            $.each(data, function (i, item) {
                labels.push(item.label);
                mapped[item.label] = item;
            });

            process(labels);
        })
      };
JSCRIPT
  end

  def autocomplete_updater(js_options={})
    raw <<JSCRIPT
      var autocompleteUpdater = function(item) {
        element = $(this)[0].$element;

        obj = element.data('mapping');
        for (var k in obj) {
            if (obj.hasOwnProperty(k)) {
                $('#' + obj[k]).val(mapped[item][k]);
            }
        }

        if (element.data('callback') != undefined && element.data('callback') != '') {
            eval(element.data('callback'));
        }

        if (element.data('return') != undefined && element.data('return') != '')
            return eval(element.data('return'));
        else
            return item;
      };
JSCRIPT
  end

  def autocomplete_sorter(js_options={})
    raw <<JSCRIPT
      var autocompleteSorter = function(items) {
        var beginswith = []
          , caseSensitive = []
          , caseInsensitive = []
          , item


        element = $(this)[0].$element;

        obj = element.data('mapping');
        for (var k in obj) {
            if (obj.hasOwnProperty(k)) {
                $('#' + obj[k]).val('');
            }
        }


        while (item = items.shift()) {
          if (!item.toLowerCase().indexOf(this.query.toLowerCase())) beginswith.push(item)
          else if (~item.indexOf(this.query)) caseSensitive.push(item)
          else caseInsensitive.push(item)
        }

        return beginswith.concat(caseSensitive, caseInsensitive)
      }
JSCRIPT
  end

  def convert_options_to_js_options(options)
    js_options = {}
    options = options.stringify_keys!
    if options['data-remote-source']
      js_options[:source] = 'autocompleteRemoteSource'
    elsif options['data-source']
      js_options[:source] = 'autocompleteSource'
    end
    js_options
  end

  class AutocompleteTag < ActionView::Helpers::Tags::TextField
    attr_accessor :js_options

    def initialize(object_name, method_name, template_object, options={}, js_options={})
      self.js_options = js_options
      super(object_name, method_name, template_object, options)
    end

    def render
      output = super

      html_options = {}
      add_default_name_and_id(html_options)

      output << @template_object.js_autocomplete_tag(html_options['id'], js_options)
      output
    end

    def self.field_type
      'text'
    end

  end

  module FormHelper
    #
    #js_options
    # source:自动完成的数组，本地匹配
    # url: 自动完成的url，ajax匹配，传入参数名称为q
    # mapping: 结果匹配元素，数组[[label, elementid1], [value: elementid2]]
    # return: 一段js脚本，注入在typeahead的updater中，显示为选中后显示的值，默认显示label
    # items: 显示匹配的数量，默认10
    # min_length: 最小激活typeahead的字符长度，默认1
    # updater: 点击选中事件，参考bootstrap api
    # matcher: 匹配元素事件，参考bootstrap api
    # highlighter:高亮显示匹配事件，参考bootstrap api
    # callback: 在点击之后执行的回调函数 example_function(this, item)
    def autocomplete(object_name, method, options={}, js_options={})
      opts = Bootstrap3::AutocompleteHelper::DEFAULT_OPTIONS.merge(options)

      js_options = convert_options_to_js_options(opts).merge(js_options)
      Bootstrap3::AutocompleteHelper::AutocompleteTag.new(object_name, method, self, opts, js_options).render
    end
  end

  module FormTagHelper
    def autocomplete_tag(name, value, options={}, js_options={})
      opts = Bootstrap3::AutocompleteHelper::DEFAULT_OPTIONS.merge(options)

      js_options = convert_options_to_js_options(opts).merge(js_options)
      output = text_field_tag(name, value, opts)
      output << js_autocomplete_tag(sanitize_to_id(name), js_options)
      output.html_safe
    end
  end
end

ActionView::Helpers::FormHelper.send(:include, Bootstrap3::AutocompleteHelper::FormHelper)
ActionView::Helpers::FormTagHelper.send(:include, Bootstrap3::AutocompleteHelper::FormTagHelper)