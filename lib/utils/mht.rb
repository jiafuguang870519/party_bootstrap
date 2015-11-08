#coding: utf-8
module Utils
  #只支持将img已经转为base64存在html中的转换，没时间写将url转为base64的代码，并且图片格式为bmp，没时间写其他的
  class Mht
    attr_accessor :content, :images

    HEADER = ['From: =?utf-8?B?08kgV2luZG93cyBJbnRlcm5ldCBFeHBsb3JlciA5ILGjtOY=?=',
              'Subject:',
              "Date: #{Time.now.strftime('%a, %d %b %Y %H:%M:%S %z')}",
              'MIME-Version: 1.0'].join("\r\n")

    BOUNDARY = "----=_NextPart_000_0000_01CCB4F2.CE5034F0"

    CONTENT_TYPE = ['Content-Type: multipart/related;',
	                  "\ttype=\"text/html\";",
	                  "\tboundary=\"#{BOUNDARY}\""].join("\r\n")

    MIME = "X-MimeOLE: Produced By BSFX MHT V0.1\r\n\r\n这是 MIME 格式的多方邮件。\r\n\r\n"
    DUMMY_FILE = "file:///c:/num.png"

    TEXT_TYPE = ['Content-Type: text/html;',
                 "\tcharset=\"utf-8\"",
                 'Content-Transfer-Encoding: quoted-printable',
                 'Content-Location: file:///C:/Users/Soaring/Documents/gzw.html'].join("\r\n")

    IMG_TYPE = ['Content-Type: image/png',
                'Content-Transfer-Encoding: base64',
                'Content-Location: FILE_NAME'].join("\r\n")

    HTML_HEADER = ['=EF=BB=BF<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">',
                   '<HTML><HEAD>',
                   '<META content=3D"text/html; charset=3Dutf-8" http-equiv=3DContent-Type>',
                   '<META name=3DGENERATOR content=3D"MSHTML 9.00.8112.16437"></HEAD>',
                   '<BODY>'].join("\r\n")

    HTML_FOOTER = '</BODY></HTML>'


    def initialize(content)
      self.content = content
      self.images = []
      decode_images
    end

    def to_mht
      mht = HEADER.dup
      mht << "\r\n"
      if images.size > 0
        mht << CONTENT_TYPE
        mht << "\r\n"
        mht << MIME
        mht << "--#{BOUNDARY}"
        mht << "\r\n"
      end
      mht << TEXT_TYPE
      mht << "\r\n\r\n"
      mht << HTML_HEADER
      mht << "\r\n"
      mht << converse_content
      mht << "\r\n"
      mht << HTML_FOOTER
      mht << "\r\n"
      mht << "--#{BOUNDARY}" << "\r\n" if images.size > 0
      images.each do |i|
        mht << IMG_TYPE.sub(/FILE_NAME/, i[0])
        mht << "\r\n\r\n"
        mht << i[1]
        mht << "\r\n\r\n"
        if images.size == images.index(i)+1
          mht << "--#{BOUNDARY}--"
        else
          mht << "--#{BOUNDARY}"
        end
        mht << "\r\n\r\n"
      end
      mht
    end

    private
    def decode_images
      i = 0
      while m = self.content.match(/.*src=\"data:image\/png;base64,(.*)\" alt.*/) do
        file_name = DUMMY_FILE.sub(/num/,i.to_s)
        self.images << [file_name, m[1]]
        self.content = self.content.sub(/src=\"data:image\/png;base64,(.*)\" alt/, "src=\"#{file_name}\" alt")
        i += 1
      end
    end

    def converse_content
      content.gsub(/=/, '=3D')
    end
  end
end