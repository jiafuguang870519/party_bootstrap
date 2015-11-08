#coding:utf-8
module Fdn
  class Message < ActiveRecord::Base
    @queue = :messages
    serialize :receivers

    validates_presence_of :sender, :subject

    belongs_to :sender, :polymorphic => true
    belongs_to :group, :class_name => 'Fdn::UserGroup'
    belongs_to :reply_of_msg, :class_name => 'Fdn::Message', :foreign_key => 'reply_of'
    belongs_to :forward_from_msg, :class_name => 'Fdn::Message', :foreign_key => 'forward_from'

    #文档附件
    has_many :file_resources, :class_name => "Fdn::FileResource", :as => :resource
    accepts_nested_attributes_for :file_resources

    #转发的文档附件
    has_many :forward_file_resources, :class_name => "Fdn::FileResource", :as => :resource
    accepts_nested_attributes_for :forward_file_resources

    has_many :received_messages
    accepts_nested_attributes_for :received_messages

    scope :order_by_created_at, -> { order("fdn_messages.created_at desc") }
    scope :out_untrashed, -> { where("fdn_messages.trashed_by_sender = 0") }
    scope :out_trashed, -> { where("fdn_messages.trashed_by_sender = 1") }
    scope :in_status, proc { |status| where("fdn_messages.status in (?)", status) }
    scope :not_in_status, proc { |status| where("fdn_messages.status not in (?)", status) }

    after_save :create_rec_msg

    def create_rec_msg
      if self.status == "sent" && self.trashed_by_sender != 1
        self.receivers.each do |r|
          receive = self.received_messages.build(receiver_type:"Fdn::User", read:0, receiver_id:r.to_i)
          receive.save
        end
      end
    end

    #发件人：form_user_id
    #收件人：to_user_ids，数组
    #标题：subject
    #内容：body
    #resource_type:Fdn::User, Wf::Process, Prs::ListedCompany
    #resource_id: 来源id
    def self.send_message(form_user_id, to_users, subject, body, resource_type, resource_id)
      form_user = Fdn::User.find(form_user_id)
      out_msg = form_user.outbox_messages.create(subject:subject,
                                                 body:body,
                                                 msg_type:resource_type,
                                                 msg_type_id:resource_id,
                                                 sender_id:form_user_id,
                                                 status:"sent",
                                                 receivers:to_users)
    end

    def msg_type_value
      case self.msg_type
        when "Fdn::User"
          "个人信息"
        when "Wf::Process"
          "办件"
        else "Prs::ListedCompany"
          "上市公司"
      end
    end


    def receivers_names
      arr = []
      if self.receivers.size > 0
        self.receivers.each do |u|
          user = Fdn::User.find(u.to_i)
          arr <<  user.org.name + "--" + user.full_name
        end
      end
      arr
    end

    #acts_as_state_machine :initial => :drafted, :column => 'status'
    #state :drafted
    #state :queued
    #state :sent
    #
    #event :queue do
    #  transitions :from => :drafted, :to => :queued
    #end
    #
    #event :send do
    #  transitions :from => [:drafted, :queued], :to => :sent
    #end

    def be_trashed(user)
      if user == self.sender && self.trashed_by_sender == 0
        self.trashed_by_sender = 1
        self.save
      end
      self
    end


    #def be_queued
    #  self.queue!
    #  #Resque.enqueue(Fdn::Message, self.id)
    #end
    #
    #def self.perform(message_id)
    #  message = Fdn::Message.find_by_id_and_status message_id, 'queued'
    #  message.perform_sending if message
    #end

    #HTML格式
    def body_html
      self.body.gsub(/\\n/, "<br/>").gsub(/\s/, "&nbsp;") unless self.body.blank?
    end

    def perform_sending
      final_receivers = self.culcalated_receivers
      if final_receivers && final_receivers.size > 0
        final_receivers.each do |u|
          self.be_sent(u.id, u.class.name)
        end
        self.send!
      end
    end

    def first_person
      if !self.receivers.size.blank?
        Fdn::User.find(self.receivers[0]).full_name
      end
    end

    def culcalated_receivers
      group_users = Fdn::User.find_all_by_id(self.group.contact_ids)
      recs = Fdn::User.find_all_by_id(self.receivers)
      (group_users + recs).uniq
    end

    private
    def be_sent(receiver_id, receiver_type)
      received_messages.create(receiver_id: receiver_id, receiver_type: receiver_type,)
    end

  end
end

