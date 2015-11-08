#coding: utf-8
module Bootstrap3::RadioHelper
  class RadiosTag < ActionView::Helpers::Tags::Base
    attr_accessor :choices

    def initialize(object_name, method_name, template_object, choices, options={})
      super(object_name, method_name, template_object, options)
      self.choices = choices
    end

    def render
      inline = @options.delete(:inline)

      add_default_name_and_id(@options)

      output = ''
      choices.each do |c|
        output << @template_object.label_tag(@options['name'], nil, class: "checkbox #{inline}") do
          ActionView::Helpers::Tags::RadioButton.new(@object_name, @method_name, @template_object, c[1], @options).render + c[0]
        end
      end

      output.html_safe
    end
  end

  module FormHelper
    def radios(object_name, method, choices, options={})
      Bootstrap3::RadioHelper::RadiosTag.new(object_name, method, self, choices, options).render
    end
  end

  module FormTagHelper
    def radios_tag(name, value, choices, options={})
      inline = options.delete(:inline)

      output = ''
      choices.each do |c|
        output << label_tag(name, nil, class: "radio #{inline}") do
          radio_button_tag(name, c[1], c[1] == value, options.merge({id: "#{sanitize_to_id(name)}_#{choices.index(c)}"})) + c[0]
        end
      end

      output.html_safe
    end
  end
end

ActionView::Helpers::FormHelper.send(:include, Bootstrap3::RadioHelper::FormHelper)
ActionView::Helpers::FormTagHelper.send(:include, Bootstrap3::RadioHelper::FormTagHelper)