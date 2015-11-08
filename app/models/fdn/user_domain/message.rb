module Fdn::UserDomain::Message
  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do
      has_many :inbox_messages, :class_name => 'Fdn::ReceivedMessage', :as => :receiver do
        def inbox(page=0)
          if page.to_i > 0
            inbox_untrashed.order_by_created_at.paginate(:page => page)
          else
            inbox_untrashed.order_by_created_at
          end
        end
        #个人信息
        def user_msg(page=0)
          if page.to_i > 0
            user_mgs.order_by_created_at.paginate(:page => page)
          else
            user_mgs.order_by_created_at
          end
        end
        #办件
        def process_msg(page=0)
          if page.to_i > 0
            process_mgs.order_by_created_at.paginate(:page => page)
          else
            process_mgs.order_by_created_at
          end
        end
        #上市公司
        def listed_comp_msg(page=0)
          if page.to_i > 0
            listed_comp_mgs.order_by_created_at.paginate(:page => page)
          else
            listed_comp_mgs.order_by_created_at
          end
        end

        def unread(page=0)
          if page.to_i > 0
            inbox_untrashed.order_by_created_at.inbox_unread.paginate(:page => page)
          else
            inbox_untrashed.order_by_created_at.inbox_unread
          end
        end

        def read(page=0)
          if page.to_i > 0
            inbox_untrashed.order_by_created_at.inbox_read.paginate(:page => page)
          else
            inbox_untrashed.order_by_created_at.inbox_read
          end
        end

        def trashed(page=0)
          if page.to_i > 0
            order_by_created_at.inbox_trashed.paginate(:page => page)
          else
            order_by_created_at.inbox_trashed
          end
        end
      end
      accepts_nested_attributes_for :inbox_messages

      has_many :outbox_messages, :class_name => 'Fdn::Message', :as => :sender do
        def outbox(page=0)
          if page.to_i > 0
            #out_untrashed.in_status('sent').order_by_created_at.paginate(:page => page)
            out_untrashed.order_by_created_at.paginate(:page => page)
          else
            #out_untrashed.in_status('sent').order_by_created_at
            out_untrashed.order_by_created_at
          end
        end

        def trashed(page=0)
          if page.to_i > 0
            out_trashed.in_status('sent').order_by_created_at.paginate(:page => page)
          else
            out_trashed.in_status('sent').order_by_created_at
          end
        end

        def queued(page=0)
          if page.to_i > 0
            out_untrashed.in_status('queued').order_by_created_at.paginate(:page => page)
          else
            out_untrashed.in_status('queued').order_by_created_at
          end
        end

        def drafted(page=0)
          if page.to_i > 0
            out_untrashed.in_status('drafted').order_by_created_at.paginate(:page => page)
          else
            out_untrashed.in_status('drafted').order_by_created_at
          end
        end
      end
      accepts_nested_attributes_for :outbox_messages
    end
  end

  module ClassMethods

  end


end