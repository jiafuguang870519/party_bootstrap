module Utils
  module Ransack
    class NonArAttribute
      attr_accessor :name

      def initialize(name)
        self.name = name
      end

      def to_s
        self.name
      end

      def inspect
        "NonArAttribute: #{self.name}"
      end
    end
  end
end