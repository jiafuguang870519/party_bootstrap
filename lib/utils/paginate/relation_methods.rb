module Utils
  module Paginate
    module RelationMethods
      def self.included(base)
        base.class_eval do
          alias_method_chain :empty?, :total_entries
        end
      end

      def empty_with_total_entries?
        if !loaded? and offset_value
          result = total_entries
          result <= offset_value
        else
          empty_without_total_entries?
        end
      end
    end
  end
end