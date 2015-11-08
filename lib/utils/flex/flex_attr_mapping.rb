#coding: utf-8
module Utils
  module Flex
    module AttrMapping
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def acts_as_flex_attr(options={})

          @flex_attr_def_contexts = []
          has_one :flex_attribute, :class_name => 'Fdn::FlexAttribute', :as => :resource
          accepts_nested_attributes_for :flex_attribute
          include InstanceMethods
        end

      end

      module InstanceMethods
        def flex_attributes(context=1)

          definition = Fdn::FlexAttrDefinition.by_resource(self.class.name).first
          global_result = definition.flex_attr_def_contexts.by_context

          column_name = definition.send("context#{context}_column")
          if column_name.blank?
            @flex_attr_def_contexts = global_result

          else
            context_value = self.send(column_name)
            context_result = definition.flex_attr_def_contexts.by_context(context, context_value)

            @flex_attr_def_contexts = global_result
            @flex_attr_def_contexts = @flex_attr_def_contexts.delete_if { |r| context_result.map { |c| c.seq }.include?(r.seq) }
            @flex_attr_def_contexts = @flex_attr_def_contexts.concat(context_result)
          end
          @flex_attr_def_contexts
        end

        def flex_attr_value(options={})
          attr_column = flex_attr_column(options)
          self.flex_attribute.send(attr_column) if self.flex_attribute && attr_column
        end

        def flex_attr_column(options={})
          opts = {:seq => 1, :context => 1}
          opts = opts.merge(options)

          flex_attributes(opts[:context]) if @flex_attr_def_contexts.blank?
          unless @flex_attr_def_contexts.empty?

            if opts[:name]
              context = @flex_attr_def_contexts.detect { |a| a.attr_name == opts[:name] }
            else
              context = @flex_attr_def_contexts.detect { |a| a.seq == opts[:seq] }
            end

            context.flex_column_name
          end
        end

        def flex_attr_values(options={})
          result = []
          opts = {:context => 1}
          opts = opts.merge(options)

          flex_attributes(opts[:context]) if @flex_attr_def_contexts.empty?
          @flex_attr_def_contexts.each do |c|
            result << [c, flex_attr_value(:seq => c.seq)]
          end
          result
        end
      end
      # To change this template use File | Settings | File Templates.
    end
  end
end