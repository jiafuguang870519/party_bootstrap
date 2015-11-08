#coding: utf-8
module Fdn::LegendsHelper
  def index_links(legend)
    if current_user.id == legend.creator.id || (current_org.id == 1 and current_user.is_a_admin? )
      [{value: '编辑', url: edit_fdn_legend_path(legend)},
       {value: '删除', url: fdn_legend_path(legend), url_method: 'delete', confirm: '确定要删除吗？'}]
    else
      [{value: '查看', url: fdn_legend_path(legend)}]
    end
  end
end
