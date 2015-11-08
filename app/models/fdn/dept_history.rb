class Fdn::DeptHistory < ActiveRecord::Base
  ##attr_accessible :ent_time, :start_time
  has_one :organization, :as=>:resource, :dependent=>:destroy
      accepts_nested_attributes_for :organization, :allow_destroy=>true

  def copy_data(obj)
      self.dept_id = obj.id
      self.seq = obj.seq
      self.internal = obj.internal
      self.type_code = obj.type_code
      self.start_time = Time.now
      self.end_time = '2999-12-31 23:59:59'
      self.save
      if self.id != nil
        @org_his = Fdn::OrganizationHistory.where("resource_type = 'Fdn::DeptHistory' and resource_id = ? " ,self.id)
        if @org_his.size != 0
          @org_his.each do |oh|
            oh.destroy
          end
        end
      end
      @org = Fdn::OrganizationHistory.create(:resource_type => 'Fdn::DeptHistory',
                                             :resource_id=>self.id,
                                             :code => obj.organization.code,
                                             :name => obj.organization.name,
                                             :description => obj.organization.description,
                                             :short_name => obj.organization.short_name,
                                             :start_time => self.start_time,
                                             :end_time => self.end_time,
                                             :lock_version => 0)
  end
end
