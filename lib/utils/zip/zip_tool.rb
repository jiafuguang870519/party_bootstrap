#coding: UTF-8
require 'zip/zip'
module Utils
  module Zip
    class ZipTool
      # 压缩文件方法
      # zip_file_name 压缩文件绝对路径，含文件名
      # file_path 要解压的目录或文件
      def self.add_to_zip_file(zip_file_name, file_path)
        # start_path 表示
        def self.add_file(start_path, file_path, zip)
          # 如果文件是一个目录则递归调用此方法
          if File.directory?(file_path)
            # 建立目录
            # 如果省略下一行代码，则当目录为空时，此目录将不会显示在压缩文件中
            zip.mkdir(file_path)
            puts "建立目录#{file_path}"
            Dir.foreach(file_path) do |filename|
              #递归调用add_file方法
              add_file("#{start_path}/#{filename}", "#{file_path}/#{filename}", zip) unless filename=="." or filename==".."
            end
          else
            # 给压缩文件中添加文件
            # start_path 被添加文件在压缩文件中显示的路径
            # file_path 被添加文件的源路径
            zip.add(start_path, file_path)
            puts "添加文件#{file_path}"
          end
        end

        # 如果文件已存在，则删除此文件
        if File.exist?(zip_file_name)
          puts "文件已存在，将会删除此文件并重新建立。"
          File.delete(zip_file_name)
        end

        # 取得要压缩的目录父路径，以及要压缩的目录名
        chdir, tardir = File.split(file_path)
        # 切换到要压缩的目录
        Dir.chdir(chdir) do
          # 创建压缩文件
          puts "开始创建压缩文件"
          Zip::ZipFile.open(zip_file_name, Zip::ZipFile::CREATE) do |zipfile|
            puts "文件创建成功，开始添加文件..."
            # 调用add_file方法，添加文件到压缩文件
            puts "已添加文件列表如下:"
            add_file(tardir, tardir, zipfile)
          end
        end
      end

      # 解压文件方法
      # zif_file_path 压缩文件的访问路径
      # extract_directory 解压文件的保存目录
      def self.extract_from_zip_file(zif_file_path, extract_directory)

        unless File.exist?(zif_file_path)
          puts "文件:#{zif_file_path}不存在."
          return 0
        end
        Dir.mkdir(extract_directory) unless File.exist?(extract_directory)
        #puts "解压文件开始，输出目录为#{extract_directory}."
        Zip::ZipFile.open(zif_file_path) do |zif_file|
          zif_file.each do |entry|
            # 通过下句打印可知，entyr是Zip::ZipEntry的对象
            # puts entry.class
            # 利用File.join构建文件存放的路径,路径为存放目录加上压缩文件的相对路径
            #print "解压文件#{Iconv.conv('UTF-8//IGNORE','GBK//IGNORE', entry::name)}......"
            #中文文件名转换
            file_name = entry::name.encode('GBK')
            entry.extract(File.join(extract_directory, file_name))
            #puts "OK"
          end
        end
        #puts "解压文件完成！"
      end
    end
  end
end


