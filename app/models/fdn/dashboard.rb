require_dependency 'fdn/dashboard_domain/layout'
require_dependency 'fdn/dashboard_domain/row'
require_dependency 'fdn/dashboard_domain/column'
require_dependency 'fdn/dashboard_domain/widget'
class Fdn::Dashboard < ActiveRecord::Base
  validates_presence_of :code, :layout, :name, :active
  validates_uniqueness_of :code, :name

  serialize :layout, Fdn::DashboardDomain::Layout

  has_many :dashboards_widgets, :class_name => 'Fdn::DashboardsWidgets'
  accepts_nested_attributes_for :dashboards_widgets

  has_many :widgets, :through => :dashboards_widgets

  belongs_to :user
  belongs_to :organization

  def render
    if layout && layout.is_a?(Fdn::DashboardDomain::Layout)
      layout.to_s.html_safe
    end
  end

end
