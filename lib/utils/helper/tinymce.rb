#coding: utf-8
module Utils
  module Helper
    module Tinymce


      def generate_js id, tinymce_options={}
        js = <<-TINYMCE_JS
        $(function() {
          $('##{id || tinymce_options[:tid]}').tinymce({
              theme: 'advanced',
              skin: 'o2k7',
              language: 'zh-cn',
              width: "#{tinymce_options[:width]||768}",
              height: "#{tinymce_options[:height]||500}",
              readonly: #{tinymce_options[:readonly]|| false },
              content_css : "/stylesheets/tinymce/style.css",
              plugins : "pagebreak,table,preview,media,searchreplace,print,contextmenu,noneditable,template,inlinepopups,fullscreen",

              // Theme options
              theme_advanced_buttons1 : "print,template,preview,code,|,bold,italic,underline,strikethrough,|,justifyleft,justifycenter,justifyright,justifyfull,|,styleselect,formatselect,fontselect,fontsizeselect,|,sub,sup,pagebreak,|,fullscreen",
              theme_advanced_buttons2 : "cut,copy,paste,|,search,replace,|,bullist,numlist,|,outdent,indent,blockquote,|,undo,redo,|,forecolor,backcolor,|,tablecontrols,table,row_props,cell_props,delete_row,delete_col,row_before,row_after,col_before,col_after,split_cells,merge_cells,|,hr,removeformat,visualaid,|,charmap",
              theme_advanced_buttons3 : "",
              theme_advanced_toolbar_location : "top",
              theme_advanced_toolbar_align : "left",
              theme_advanced_statusbar_location : "bottom",
              theme_advanced_resizing : true,
              theme_advanced_resize_horizontal : false,
              theme_advanced_fonts : "宋体=宋体;"+
                "仿宋=仿宋;"+
                "方正大标宋简体=方正大标宋简体;"+
                "方正小标宋简体=方正小标宋简体;"+
                "楷体=楷体;"+
                "黑体=黑体;"+
                "微软雅黑=微软雅黑;"+
                "Andale Mono=andale mono,times;"+
                "Arial=arial,helvetica,sans-serif;"+
                "Arial Black=arial black,avant garde;"+
                "Comic Sans MS=comic sans ms,sans-serif;"+
                "Courier New=courier new,courier;"+
                "Helvetica=helvetica;"+
                "Tahoma=tahoma,arial,helvetica,sans-serif;"+
                "Times New Roman=times new roman,times;"+
                "Verdana=verdana,geneva;",
              theme_advanced_font_sizes : "一号=28pt,二号=21pt,小二号=18pt,三号=16pt,四号=14pt,小四号=12pt,五号=10.5pt,小五号=9pt"

          });
        });
        TINYMCE_JS
      end

      module BuilderMethods
        #include Utils::Helper::Tinymce

        def tinymce method, options={}, tinymce_options={}
          self.text_area(method, options) + javascript_tag(generate_js(options[:id]||default_id(self.object.class.name, method), tinymce_options))
        end
      end

      module ViewHelpers
        #include Utils::Helper::Tinymce

        def tinymce_tag name, content = '', options = {}, tinymce_options={}
          text_area_tag(name, content, options) + javascript_tag(generate_js(options[:id]||name, tinymce_options))
        end

        def tinymce object_name, method, options={}, tinymce_options={}
          text_area(object_name, method, options) + javascript_tag(generate_js(options[:id]||default_id(object_name, method), tinymce_options))
        end
      end
    end
  end
end