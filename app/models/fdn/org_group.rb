module Fdn
  class OrgGroup < ActiveRecord::Base
    serialize :org_ids
  end
end

