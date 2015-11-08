#coding: utf-8
# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'rexml/document'
module Utils
  module Xml
    class XmlTool
      include REXML

      def self.modify_xml_file(xml_file_name, elem_path, elem_name, elem_text)
        File.open(xml_file_name, 'r') do |file|
          doc = Document.new(file)
          doc.elements.each(elem_path) do |e|
            if e.attributes["name"] == elem_name
              e.text = elem_text
            end
          end
          File.open(xml_file_name, 'w') do |xml_file|
            doc.write(xml_file)
          end
        end
      end

      def self.modify_xml_value(xml_file, elem_path, elem_name, elem_text)
        doc = Document.new(xml_file)
        doc.elements.each(elem_path) do |e|
          if e.attributes["name"] == elem_name
            e.text = elem_text
          end
        end
        xml_file = doc
      end

    end
  end
end

