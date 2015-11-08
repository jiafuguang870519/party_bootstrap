class Fdn::WidgetAction < ActiveRecord::Base
  ##attr_accessible :href, :onclick, :value, :icon

  belongs_to :widget
end
