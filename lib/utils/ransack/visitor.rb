require 'utils/ransack/non_ar_attribute'
module Utils
  module Ransack
    module Visitor
      def self.included(base)
        base.class_eval do
          alias_method_chain :visit_Ransack_Nodes_Condition, :special_attr
        end
      end

      def visit_Ransack_Nodes_Condition_with_special_attr(object)
        unless object.attributes.detect {|a| a.name.start_with?('zzz_')}
          visit_Ransack_Nodes_Condition_without_special_attr(object)
        end
      end
    end
  end
end