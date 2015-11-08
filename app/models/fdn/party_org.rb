class Fdn::PartyOrg < ActiveRecord::Base
  require 'spreadsheet'
  require 'spreadsheet/excel'
  require 'spreadsheet/excel/workbook'
  require 'spreadsheet/excel/worksheet'

  def self.file_import(file)

    Spreadsheet.client_encoding = "UTF-8"
    spreadsheet = open_spreadsheet(file)

    sheet = spreadsheet.worksheet 0

    (2..sheet.row_count-1).each do |row|

      ent_work = Pty::EntTrainingRegistration.new
      ent_work.user_name =sheet.row(row)[2]
      ent_work.sex=sheet.row(row)[3]
      ent_work.age= sheet.row(row)[4]
      ent_work.educational_background =sheet.row(row)[5]
      ent_work.work_time =sheet.row(row)[6]
      ent_work.apply_party_time= sheet.row(row)[7]
      ent_work.contact =sheet.row(row)[8]
      ent_work.save
    end


  end


  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
      when ".xls" then
        Spreadsheet.open file.path
      when ".xlsx" then
        Spreadsheet.open file.path
      else
        raise "Unknown file type: #{file.original_filename}"
    end
  end
end
