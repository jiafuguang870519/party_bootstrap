class Fdn::OldCode < ActiveRecord::Base
  has_and_belongs_to_many :organizations
end
# == Schema Information
#
# Table name: fdn_old_codes
#
#  id         :integer(4)      not null, primary key
#  code       :string(255)
#  name       :string(255)
#  short_name :string(255)
#  created_at :datetime
#  updated_at :datetime
#

