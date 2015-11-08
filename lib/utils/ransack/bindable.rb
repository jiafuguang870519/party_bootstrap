require 'utils/ransack/non_ar_attribute'
module Utils
  module Ransack
    module Bindable
      def self.included(base)
        base.class_eval do
          alias_method_chain :attr, :special_attr
          alias_method_chain :bound?, :special_attr
        end
      end

      def attr_with_special_attr
        @attr ||= ransacker ? ransacker.attr_from(self) : (
          attr_name.start_with?('zzz_') ? Utils::Ransack::NonArAttribute.new(attr_name) : context.table_for(parent)[attr_name]
        )
      end

      def bound_with_special_attr?
        if attr_name.start_with?('zzz')
          true
        else
          attr_name.present? && parent.present?
        end
      end
    end
  end
end