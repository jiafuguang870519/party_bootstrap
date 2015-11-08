#coding: utf-8
module Utils
  module Hash
    module Enhancer

      def self.included(base)
        base.class_eval do

          def self.transform_h(names)
            names.each do |k|
              define_method k.to_s do
                @h[k]
              end
            end
          end

        end
      end
    end
  end
end