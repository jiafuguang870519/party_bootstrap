# Be sure to restart your server when you modify this file.

require 'utils/migration/table_definition'
require 'utils/flex/flex_attr_mapping'
require 'utils/json/custom_json'
require 'utils/num_to_cn'
require 'utils/xml/xml_tool'
#require 'utils/ransack/search'
require 'utils/ransack/grouping'
require 'utils/ransack/bindable'
require 'utils/ransack/context'
require 'utils/ransack/active_record/context'
require 'utils/ransack/visitor'
require 'utils/paginate/relation_methods'
require 'will_paginate/active_record'

ActiveRecord::Base.send(:include, Utils::Flex::AttrMapping)
ActiveRecord::ConnectionAdapters::TableDefinition.send :include, Utils::Migration::TableDefinition
#Ransack::Search.send(:include, Utils::Ransack::Search)
Ransack::Nodes::Grouping.send(:include, Utils::Ransack::Grouping)
Ransack::Nodes::Bindable.send(:include, Utils::Ransack::Bindable)
Ransack::Context.send(:include, Utils::Ransack::Context)
Ransack::Adapters::ActiveRecord::Context.send(:include, Utils::Ransack::ActiveRecord::Context)
Ransack::Visitor.send(:include, Utils::Ransack::Visitor)


WillPaginate::ActiveRecord::RelationMethods.send(:include, Utils::Paginate::RelationMethods)
WillPaginate.per_page = 15

Date::DATE_FORMATS[:timeline] = '%Y,%m,%d'
