#coding: utf-8
module Fdn::OrganizationDomain::Validator

  def self.included(base)
    base.extend(ClassMethods)

    base.class_eval do
      # validates_presence_of :code, :if => proc { |attr| attr.resource_type != 'Fdn::Enterprise' }
      validates_presence_of :name
      validates :code, :uniqueness => true, :presence => true
      include Fdn::OrganizationDomain::Validator::InstanceMethods
    end
  end

  module ClassMethods

  end

  module InstanceMethods


  end
end