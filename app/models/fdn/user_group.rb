#coding: utf-8
module Fdn
  class UserGroup < ActiveRecord::Base
    validates_presence_of :name
    serialize :contact_ids

    scope :sb, lambda{|user_id| where("created_by=?", user_id)}
    
    def contact_id_str
      contact_ids.join(",")
    end

    def self.save_group(name, user_ids)
      g = Fdn::UserGroup.find_by_name(name)
      if g
        g.contact_ids = user_ids
        g.save
      else
        Fdn::UserGroup.create(:name=> name, :contact_ids => user_ids)
      end
    end
  end
end

