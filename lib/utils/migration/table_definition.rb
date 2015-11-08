#coding: utf-8
#这个module扩展了ActiveRecord::ConnectionAdapters::TableDefinition，
#使其可以在migration文件中用t.tracer的方式添加2个追踪字段，用于记录创建人和最后修改人的id
module Utils
  module Migration
    module TableDefinition

      #使用方法 t.tracer
      def tracer
        column :created_by, :integer
        column :updated_by, :integer
      end
    end
  end
end