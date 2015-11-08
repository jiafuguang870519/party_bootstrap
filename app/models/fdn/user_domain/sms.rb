module Fdn::UserDomain::Sms
  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do
    end
  end

  module ClassMethods

  end

  def send_sms(sms_text)
    mobile = self.user_information.mobile
    if mobile
      outbox = Fdn::Outbox.new
      outbox.number = Fdn::Lookup::SMS_COUNTRY_CODE + mobile.strip
      outbox.text = self.full_name + ":" + sms_text + Fdn::Lookup::SMS_END_TEXT
      outbox.created_by = self.id
      outbox.save
    end
  end
end