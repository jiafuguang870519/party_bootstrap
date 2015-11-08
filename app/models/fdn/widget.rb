class Fdn::Widget < ActiveRecord::Base
  validates_presence_of :code, :name, :title
  validates_uniqueness_of :code, :name

  has_many :dashboards_widgets, :class_name => 'Fdn::DashboardsWidgets'
  has_many :actions, :class_name => 'Fdn::WidgetAction'
  accepts_nested_attributes_for :actions
end
