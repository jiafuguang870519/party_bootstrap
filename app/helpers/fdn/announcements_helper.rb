#coding: utf-8
module Fdn::AnnouncementsHelper
  def announcement_index_links(announcement)
    if current_user.id == announcement.creator.id || (current_org.id == 1 and current_user.is_a_admin? )
      [{value: '查看', url: fdn_announcement_path(announcement)},
       {value: '编辑', url: edit_fdn_announcement_path(announcement)},
       {value: '删除', url: fdn_announcement_path(announcement), url_method: 'delete', confirm: '确定要删除吗？'}]
    else
      [{value: '查看', url: fdn_announcement_path(announcement)}]
    end
  end
end