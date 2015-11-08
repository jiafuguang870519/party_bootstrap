#coding: utf-8
module Bootstrap3::LayerHelper
  extend ActiveSupport::Concern

  def close_window_show_tips(window_index, tips)
    javascript_tag do
      raw <<JSCRIPT
       parent.layer.tips('#{tips}', '#count-info', {style: ['background-color:#78BA32; color:#fff', '#78BA32'],maxWidth:285,time: 5,closeBtn:[0, true]});
       parent.location.reload();
       parent.layer.close(#{window_index});
JSCRIPT
    end

  end

  def close_window_refresh_div_show_tips(window_index, url, params, tips)
    javascript_tag do
      raw <<JSCRIPT
       parent.layer.tips('#{tips}', '#count-info', {style: ['background-color:#78BA32; color:#fff', '#78BA32'],maxWidth:285,time: 5,closeBtn:[0, true]});
       parent.$.jq_remote_get('#{url}',{#{params},'format': 'js'});
       parent.layer.close(#{window_index});
JSCRIPT
    end
  end

  def delete_refresh_div_show_tips(tips)
    javascript_tag do
      raw <<JSCRIPT
        layer.tips('#{tips}', '#count-info', {style: ['background-color:#78BA32; color:#fff', '#78BA32'],maxWidth:285,time: 5,closeBtn:[0, true]});
JSCRIPT
    end
  end

  def open_window_js(title, url, width, height)
    raw <<JSCRIPT
       MAIN_LAYER_WINDOW = $.layer({type: 2,shadeClose: false,fix: true,title: '#{title}',maxmin: true,iframe: {src : '#{url}'},area: ['#{width}' , '#{height}']});
JSCRIPT

  end

  def open_confirm_window_js(url, params,confirm,tips)
    raw <<JSCRIPT
       MAIN_LAYER_WINDOW = parent.layer.confirm('#{confirm}',function(index){
           parent.layer.tips('#{tips}', '#count-info', {style: ['background-color:#78BA32; color:#fff', '#78BA32'],maxWidth:285,time: 5,closeBtn:[0, true]});
           parent.$.jq_remote_get('#{url}',{#{params},'format': 'js'});
           parent.layer.close(MAIN_LAYER_WINDOW);
       });
JSCRIPT

  end

end