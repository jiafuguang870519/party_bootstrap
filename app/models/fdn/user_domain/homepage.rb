module Fdn::UserDomain::Homepage
  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do
      has_one :homepage
    end
  end

  module ClassMethods

  end
end