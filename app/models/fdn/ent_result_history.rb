class Fdn::EntResultHistory < ActiveRecord::Base
  # #attr_accessible :title, :body
  belongs_to :enterprise
  belongs_to :row_template , :class_name => 'Prs::RowTemplate' , :foreign_key => 'row_template_id'
  belongs_to :currency, :class_name => 'Fdn::Lookups::Currency', :foreign_key => 'currency_code', :primary_key => 'code'
end
