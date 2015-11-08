module Fdn::UserDomain::PredefOpinion
  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do
      has_many :predef_opinions do
        def by_type_code(code)
          where('type_code =?', code)
        end
      end
      accepts_nested_attributes_for :predef_opinions
    end
  end

  module ClassMethods

  end
end