#coding: utf-8
class ActorSweeper < ActionController::Caching::Sweeper
  #observe Oa::SentDocument,Fdn::User, Fdn::Role, Fdn::Menu, Fdn::Organization, Fdn::Lookup, Fdn::Profile, Fdn::Enterprise, Fdn::OrgHierarchy,
  #        Fdn::OrgHieVersion, Fdn::UserInformation, Oa::DutyList, Oa::DutyListPerson, Oa::DutyListRule, Hr::Person, Hr::Position,
  #        Hr::Assignment, Oa::FaBooking, Oa::FaPoRequirement, Oa::FaPoReqItem, Oa::FaReceipt, Oa::FaRecItem, Oa::FaActivity, Oa::Item,
  #        Oa::Vehicle, Oa::VehicleMaintanence, Oa::Announcement, Oa::News, Oa::NewsCategory, Oa::VehicleUsage, Wf::ProcessDefinition,
  #        Wf::Participant, Fdn::Event, Oa::Meeting,
  #        Oa::RecvDocument, Oa::SentDocVer, Oa::KnowledgeCategory, Oa::KnowledgeMain
  observe Fdn::Role, Fdn::User, Fdn::Organization, Fdn::Enterprise, Fdn::Dept, Fdn::Announcement,
          Fdn::Legend###### FDN
          #########NS

  def before_create(record)
    if controller && controller.session
      record.created_by = controller.session[:user_id] if record.respond_to?('created_by')
      record.updated_by = controller.session[:user_id] if record.respond_to?('updated_by')
      if record.respond_to?('organization_id')
        record.organization_id= controller.session[:org_id] unless record.organization_id
      end
    end
  end

  def before_update(record)
    (record.updated_by = controller.session[:user_id]) if controller.try(:session) && record.respond_to?('updated_by')
  end

end
