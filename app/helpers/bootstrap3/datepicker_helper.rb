#coding: utf-8
module Bootstrap3::DatepickerHelper
  extend ActiveSupport::Concern

  def datepicker_include_tag
    output = javascript_include_tag('/js/plugins/datapicker/bootstrap-datepicker.js')
    output << stylesheet_link_tag('/css/plugins/datapicker/datepicker3.css')
  end

  #
  #js_options
  # format: yyyy-mm-dd, yyyy/mm/dd.....
  # week_start: 0-6
  # start_date: 开始日期
  # end_date: 结束日期
  # days_of_week_disabled: 一周限制几天不可选, 0,1,2,3,4,5,6
  # autoclose: 选取后自动关闭, true, false
  # start_view: 0..月，1..年，2..10年
  # today: linked
  # today_highlight: true, false
  # keyboard_nav: true, false
  # language: zh-CN
  # force_parse: true, false
  # min_view_mode: 0..日,1..月,2..年
  def js_datepicker_tag(id, js_options={})
    format = js_options[:format] || 'yyyy-mm-dd'
    week_start = js_options[:week_start] || 0
    start_date = js_options[:start_date] || '1900-1-1'
    end_date = js_options[:end_date] || '2099-12-31'
    days_of_week_disabled = js_options[:days_of_week_disabled] || ''
    autoclose = js_options[:autoclose] || 'true'
    start_view = js_options[:start_view] || 0
    today = js_options[:today] || 'linked'
    today_highlight = js_options[:today_highlight] || 'true'
    keyboard_nav = js_options[:keyboard_nav] || 'true'
    language = 'zh-CN'
    force_parse = js_options[:force_parse] || 'false'
    min_view_mode = js_options[:min_view_mode] || 0

    javascript_tag do
      raw <<JSCRIPT
          $(document).ready(function() {
            $('##{id}').datepicker({
              format: '#{format}',
              weekStart: #{week_start},
              startDate: '#{start_date}',
              endDate: '#{end_date}',
              daysOfWeekDisabled: '#{days_of_week_disabled}',
              autoclose: #{autoclose},
              startView: #{start_view},
              todayBtn: '#{today}',
              todayHighlight: #{today_highlight},
              keyboardNavigation: #{keyboard_nav},
              language: '#{language}',
              forceParse: #{force_parse},
              minViewMode: #{min_view_mode}
            });
          });

JSCRIPT
    end
  end

  #js_options 感觉没啥可以解释的
  #  minute_step: 15
  #  show_second: true, false
  #  second_step: 15
  #  default_time: current, value, false
  #  show_meridian: true, false 是否12小时制
  #  show_inputs: true, false
  #  disable_focus: true, false
  def js_timepicker_tag(id, js_options={})
    template = 'dropdown'
    minute_step = js_options[:minute_step] || 15
    show_second = js_options[:show_second] || 'false'
    second_step = js_options[:second_step] || 15
    default_time = js_options[:default_time] || 'current'
    show_meridian = js_options[:show_meridian] || 'false'
    show_inputs = js_options[:show_inputs] || 'true'
    disable_focus = js_options[:disable_focus] || 'false'
    #puts '-----'
    #puts default_time
    javascript_tag do
      raw <<JSCRIPT
        $(document).ready(function() {
          $('##{id}').timepicker({
            template: '#{template}',
            minuteStep: #{minute_step},
            showSecond: #{show_second},
            secondStep: #{second_step},
            defaultTime: '#{default_time}',
            showMeridian: #{show_meridian},
            showInputs: #{show_inputs},
            disableFocus: #{disable_focus}
          });
        });
JSCRIPT
    end
  end

  def js_datetimepicker_tag(hidden_id, datepicker_name, timepicker_name)
    javascript_tag do
      raw <<JSCRIPT
        $(document).ready(function() {
          $('##{sanitize_to_id(datepicker_name)}').datepicker().on('changeDate', function(e){
            $('##{hidden_id}').val(
              $('##{sanitize_to_id(datepicker_name)}').val() + ' ' + $('##{sanitize_to_id(timepicker_name)}').val()
            );
          });

          $('##{sanitize_to_id(timepicker_name)}').timepicker().on('changeTime', function(e){
            $('##{hidden_id}').val(
              $('##{sanitize_to_id(datepicker_name)}').val() + ' ' + $('##{sanitize_to_id(timepicker_name)}').val()
            );
          });
        });
JSCRIPT
    end
  end

  def strftime(value)
    if value
      if value.is_a?(Date) || value.is_a?(DateTime)
        value_str = value.strftime(Fdn::Lookup::SHORT_TIME)
      else
        value_str = value
      end

      if value_str.is_a? String
        value_str.match(/^(\d{4}-\d{1,2}-\d{1,2})?\s?(\d{1,2}:\d{1,2})?$/)
      end
    else
      []
    end
  end

  class DatepickerTag < ActionView::Helpers::Tags::TextField
    attr_accessor :js_options

    def initialize(object_name, method_name, template_object, options={}, js_options={})
      self.js_options = js_options
      super(object_name, method_name, template_object, options)
    end

    def render
      output = @template_object.embed_input('th') do
        super
      end

      html_options = {}
      add_default_name_and_id(html_options)

      output << @template_object.js_datepicker_tag(html_options['id'], js_options)
      output.html_safe
    end

    def self.field_type
      'text'
    end
  end

  class TimepickerTag < ActionView::Helpers::Tags::TextField
    attr_accessor :js_options

    def initialize(object_name, method_name, template_object, options={}, js_options={})
      self.js_options = js_options
      super(object_name, method_name, template_object, options)
    end

    def render
      output = @template_object.embed_input('time') do
        super
      end

      html_options = {}
      add_default_name_and_id(html_options)

      if value(@object)
        js_options[:default_time] = value(@object)
      end

      output << @template_object.js_timepicker_tag(html_options['id'], js_options)
      output.html_safe
    end

    def self.field_type
      'text'
    end
  end

  class DateTimepickerTag < ActionView::Helpers::Tags::TextField
    attr_accessor :date_options, :time_options

    def initialize(object_name, method_name, template_object, options={}, date_options={}, time_options={})
      self.date_options = date_options
      self.time_options = time_options
      super(object_name, method_name, template_object, options)
    end

    def render
      output = super
      time_value = value(@object)

      time_str = @template_object.strftime(time_value)

      html_options = {}
      add_default_name_and_id(html_options)

      hidden_id = html_options['id']
      datepicker_name = 'date'+html_options['name']
      timepicker_name = 'time'+html_options['name']

      output << @template_object.datepicker_tag(datepicker_name, time_str[1], @options, date_options)
      output << @template_object.timepicker_tag(timepicker_name, time_str[2], @options, time_options)
      output << @template_object.js_datetimepicker_tag(hidden_id, datepicker_name, timepicker_name)
      output.html_safe
    end

    def self.field_type
      'text'
    end
  end

  module FormHelper
    def datepicker(object, method, options={}, js_options={})
      Bootstrap3::DatepickerHelper::DatepickerTag.new(object, method, self, options, js_options).render
    end

    def timepicker(object, method, options={}, js_options={})
      Bootstrap3::DatepickerHelper::TimepickerTag.new(object, method, self, options, js_options).render
    end

    def datetimepicker(object_name, method, options={}, date_options={}, time_options={})
      Bootstrap3::DatepickerHelper::DateTimepickerTag.new(object_name, method, self, options, date_options, time_options).render
    end

  end

  module FormTagHelper
    #
    #js_options
    # format: yyyy-mm-dd, yyyy/mm/dd.....
    # week_start: 0-6
    # start_date: 开始日期
    # end_date: 结束日期
    # days_of_week_disabled: 一周限制几天不可选, 0,1,2,3,4,5,6
    # autoclose: 选取后自动关闭, true, false
    # start_view: 0..月，1..年，2..10年
    # today: linked
    # today_highlight: true, false
    # keyboard_nav: true, false
    # language: zh-CN
    # force_parse: true, false
    def datepicker_tag(name, value, options={}, js_options={})
      id = sanitize_to_id(name)
      default_options = {id: id}

      output = embed_input('th') do
        text_field_tag(name, value, default_options.merge(options))
      end
      output << js_datepicker_tag(id, js_options)
      raw output
    end

    def timepicker_tag(name, value, options={}, js_options={})
      id = sanitize_to_id(name)
      default_options = {id: id}

      output = embed_input('time') do
        text_field_tag(name, value, default_options.merge(options))
      end

      if value
        js_options[:default_time] = value
      end

      output << js_timepicker_tag(id, js_options)
      raw output
    end

    def datetimepicker_tag(name, value, options={}, date_options={}, time_options={})
      output = hidden_field_tag(name, value, options)

      time_str = @template_object.strftime(value)

      hidden_id = sanitize_to_id(name)
      datepicker_name = 'date_'+name
      timepicker_name = 'time_'+name

      output << datepicker_tag(datepicker_name, time_str[1], options, date_options)
      output << timepicker_tag(timepicker_name, time_str[2], options, time_options)
      output << js_datetimepicker_tag(hidden_id, datepicker_name, timepicker_name)

      raw output
    end
  end

end

ActionView::Helpers::FormHelper.send(:include, Bootstrap3::DatepickerHelper::FormHelper)
ActionView::Helpers::FormTagHelper.send(:include, Bootstrap3::DatepickerHelper::FormTagHelper)