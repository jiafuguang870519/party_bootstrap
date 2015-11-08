module Utils
  module Ransack
    module Grouping
      def self.included(base)
        base.class_eval do
          #alias_method_chain :method_missing, :special_attr
          alias_method_chain :attribute_method?, :special_attr
        end
      end

      #def method_missing_with_special_attr(method_id, *args)
      #  method_name = method_id.to_s
      #  writer = method_name.sub!(/\=$/, '')
      #  puts method_name
      #  puts 'in grouping'
      #  if method_name.start_with?('zzz_')
      #    writer ? write_attribute(method_name, *args) : read_attribute(method_name)
      #  else
      #    method_missing_without_special_attr(method_id, *args)
      #  end
      #end

      def attribute_method_with_special_attr?(name)
        name2 = strip_predicate_and_index(name)
        if name2.start_with?('zzz_') && !name2.end_with?('before_type_cast')
          true
        else
          attribute_method_without_special_attr?(name)
        end
      end
    end
  end
end