module Utils
  module Ransack
    module Context
      def self.included(base)
        base.class_eval do
          alias_method_chain :bind, :special_attr
        end
      end

      def bind_with_special_attr(object, str)
        #puts 'new bind'
        if str.start_with?('zzz_')
          object.parent = self.object
          object.attr_name = str
        else
          object.parent, object.attr_name = @bind_pairs[str]
        end
      end
    end
  end
end