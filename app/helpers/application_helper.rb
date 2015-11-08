#coding:utf-8
module ApplicationHelper
  #计算序号
  #collection: 集合
  #obj: 集合中的元素
  #per_page: 每页显示记录数
  def seq(collection, obj, p_page, p_per_page=nil)
    if p_per_page.nil?
      per_page = Fdn::Lookup::PAGE_PER_COUNT
    else
      per_page = p_per_page
    end

    page = p_page.to_i
    if page < 1
      page = 1
    end

    (page - 1) * per_page + collection.index(obj) + 1
  end

  #去页面配置的assets
  #可以在config/settings中配置页面的asset js css文件
  def view_assets_tag
    asset_js_controller = Settings.assets.javascript.send(params[:controller]).nil? ? nil : Settings.assets.javascript.send(params[:controller]).send(:all)
    asset_css_controller = Settings.assets.css.send(params[:controller]).nil? ? nil : Settings.assets.css.send(params[:controller]).send(:all)
    asset_js_action = Settings.assets.javascript.send(params[:controller]).nil? ? nil : Settings.assets.javascript.send(params[:controller]).send(params[:action])
    asset_css_action = Settings.assets.css.send(params[:controller]).nil? ? nil : Settings.assets.css.send(params[:controller]).send(params[:action])
    js_files = []
    js_files = js_files + asset_js_controller unless asset_js_controller.nil?
    js_files = js_files + asset_js_action  unless asset_js_action.nil?
    css_files = []
    css_files = css_files + asset_css_controller unless asset_css_controller.nil?
    css_files = css_files + asset_css_action unless asset_css_action.nil?
    content = ''
    js_files.each do |js|
      content << javascript_include_tag(js, 'data-turbolinks-track' => true)
    end
    css_files.each do |css|
      content << stylesheet_link_tag(css)
    end
    raw content
  end

  def errors_for(object, message=nil)
    html = ''
    if object && object.errors.present?
      html = alert("#{object.class.model_name.human}：#{I18n.t('activerecord.errors.template.header.other')}", object.errors.full_messages)
    end
    html
  end

  #可以传参数的javascript_include_tag
  def javascript_include_tag_with_p(path)
    javascript_tag nil, :src => path
  end

  #截取字符串
  def limit_word(str, limit_length=20)
    truncate(str, :length => limit_length)
  end

  #用于动态行删除
  def js_remove_line_tag
    rand = Random.new(Time.now.to_i)
    id = rand.rand(1e16).to_i
    #bs_a(confirm: '确认删除吗？',js: "$('##{id.to_s}').parents('tr:first').remove();", id: id.to_s, class: 'fa fa-minus')
    bs_a(js: "if(confirm('确认删除吗？')==true){$('##{id.to_s}').parents('tr:first').remove();} else {return false;}", id: id.to_s, class: 'fa fa-minus')
  end

  #加了删除next， 因为改了ui以后，用fields_for会在tr后面自动生成一个hidden id也要删掉
  def remote_remove_line_tag(f, url)
    rand = Random.new(f.object.object_id + Time.now.to_i)
    id = rand.rand(1e16).to_i
    #puts '==='
    #puts f.object_name
    bs_a(js: "if(confirm('确认删除吗？')==true){$.get('#{url}', {format: 'js'});
          $('##{id.to_s}').parents('tr:first').nextAll('input[name=\"#{f.object_name}[id]\"]').remove();
          $('##{id.to_s}').parents('tr:first').remove();} else {return false;}", id: id.to_s, class: 'fa fa-minus')
    #bs_a(confirm: '确认删除吗？', js: "$.get('#{url}', {format: 'js'});
    #      $('##{id.to_s}').parents('tr:first').nextAll('input[name=\"#{f.object_name}[id]\"]').remove();
    #      $('##{id.to_s}').parents('tr:first').remove();", id: id.to_s, icon: 'fa-minus')
  end

  def remove_line_tag(f, url)
    if f.object.new_record?
      js_remove_line_tag
    else
      remote_remove_line_tag(f, url)
    end
  end

  def req(str)
    content_tag('span', :class => 'req-field') do
      raw(str)
    end
  end

end
