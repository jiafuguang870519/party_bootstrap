module Utils
  module Ransack
    module ActiveRecord
      module Context
        def self.included(base)
          base.class_eval do
            alias_method_chain :type_for, :special_attr
          end
        end

        def type_for_with_special_attr(attr)
          return nil if attr.name.start_with?('zzz_')
          type_for_without_special_attr(attr)
        end
      end
    end
  end
end