#coding: utf-8
class Fdn::DashboardDomain::Widget
  # To change this template use File | Settings | File Templates.
  attr_accessor :code

  def initialize(code='')
    self.code= code
  end

  def self.refresh_widget(code)
    widget = Fdn::Widget.find_by_code(code)
    widget.refresh_js(code, widget.url, widget.params) if widget
  end

  def to_s(thumbnails=false) #TODO thumbnails是啥
    widget = Fdn::Widget.find_by_code(code)
    if widget
      title = widget.title
      url = widget.url
      bold = widget.bold == 1 ? 'widget-bold' : ''
      higher = widget.higher == 1 ? 'widget-higher' : ''
      params = widget.params
      actions = widget.actions

      if thumbnails
        output = "<div class='thumb-content' id='thumb_#{code}'>"
        output <<
            %Q(
            <script type="text/javascript">
              $(document).ready(function() {
                #{refresh_js(code, url, params, thumbnails) }

              });
            </script>
            ) unless url.blank?
        output << '</div>'
        output.html_safe
      else
        if code == 'ntd' #new page zll
          output = "<div class='widget #{bold} #{higher}' id='widget_#{code}'>"
          output << '<div class="widget-content">'  #加了之后，页面多了div导致内容变小
          output <<
              %Q(
            <script type="text/javascript">
              $(document).ready(function() {
                #{refresh_js(code, url, params) }

              });
            </script>
            ) unless url.blank?

          output << '</div>'
          output << '</div>'
          output
        else
          output = "<div class='widget #{bold} #{higher}' id='widget_#{code}'>"
          if code == 'domain' || code == 'district_dynamic' || code == 'nc_list' || code == 'nc_list_nc'
            output << "<div class=' widget-header widget-header3'>"
          else
            output << "<div class='widget-header'>"
          end
          output << title + widget_action(actions)
          output << "</div>"
          output << '<div class="widget-content">'
          output <<
              %Q(
            <script type="text/javascript">
              $(document).ready(function() {
                #{refresh_js(code, url, params) }

              });
            </script>
            ) unless url.blank?

          output << '</div>'
          output << '</div>'
          output
        end
      end

    else
      if thumbnails
        title = '错误'
        output = "<div class='thumb-content' id='thumb_#{code}'>"
        output << title
        output << '</div>'
        output
      else
        title = '错误'
        output = "<div class='widget' id='widget_#{code}'>"
        output << "<div class='widget-header'>"
        output << title
        output << "</div>"
        output << '<div class="widget-content">'
        output << '</div>'
        output << '</div>'
        output
      end

    end

  end

  def refresh_js(code, url, params, thumbnails=false)
    if params
      param_array = params.split(',')
    else
      param_array = []
    end

    if thumbnails
      %Q(
          $.get('#{url}', {wid: '#{"thumb_#{code}"}',
                           #{param_array.empty? ? '' : param_array.map { |p| "#{p}: $('##{p}').val()" }.join(',') + ','}
                           width: $('##{"thumb_#{code}"}').innerWidth(),
                           height : $('##{"thumb_#{code}"}').innerHeight()})
      )
    else
      %Q(
          $.get('#{url}', {wid: '#{"widget_#{code}"}',
                           #{param_array.empty? ? '' : param_array.map { |p| "#{p}: $('##{p}').val()" }.join(',') + ','}
                           width: $('##{"widget_#{code}"} .widget-content').innerWidth(),
                           height : $('##{"widget_#{code}"}').innerHeight() - $('##{"widget_#{code}"} .widget-header').outerHeight()})
      )
    end

  end

  def widget_action(actions = [])
    output = ''
    unless actions.empty?
      output = '<span class="widget-menu">'

      actions.each do |a|
        options = ["title='#{a.value}'"]
        if a.href
          options << "href='#{a.href}'"
        elsif a.onclick
          options << "href='#'"
          options << "onclick='#{a.onclick}'"
        end
        output << "<a #{options.join(' ')}>#{a.value}</a>"
      end

      output << '</span>'
    end
    output
  end
end