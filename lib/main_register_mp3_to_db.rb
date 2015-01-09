#! ruby -Ku
# encoding: utf-8

require_relative 'fileSearch'
require_relative 'entities/mp3file'
require_relative 'encodeUtil'
require 'mp3info'
require 'sequel'

DB = Sequel.sqlite('db/mp3_kara.sqlite')
mp3files = DB[:mp3files]

dir_list_path = File.dirname(__FILE__) + "/assets/dir.lst"

dir_lst = FileSearch.get_dir_list(dir_list_path)
dir_lst.each do |dir_path|
  next if dir_path[0] == '#'
  p dir_path
  files = FileSearch.search_mp3(dir_path)


  files.each do |file|
    Mp3Info.open(file){ |mp3|
      mp3.tag2.options[:encoding] = 0

      @artist_name = mp3.tag.artist
      @title = mp3.tag.title
      @album = mp3.tag.album

      if mp3.hastag2? then

        @artist_name = mp3.tag2.TPE1
        @title = mp3.tag2.TIT2
        @album = mp3.tag2.TALB
      end

      @artist_name = strict_convert_into_utf16(@artist_name)
      #@title = strict_convert_into_utf16(@title)
      #@album = strict_convert_into_utf16(@album)

      mp3File = Mp3File.new(file,
                            File.basename(file),
                            @artist_name,
                            @title,
                            @album,
                            File.mtime(file),
                            File.size(file))
      p mp3.tag2.encode("Shift_JIS") if mp3.tag2.TPE1
      p unescape(mp3File.artist)
      next if mp3files.filter(:file_path => file).all.count >= 1


      mp3files.insert(:file_path => mp3File.file_path,
                      :file_name => mp3File.file_name,
                      :artist => sanitize_string(mp3File.artist),
                      :title => sanitize_string(mp3File.title),
                      :album => sanitize_string(mp3File.album),
                      :d_get => mp3File.d_get,
                      :size => mp3File.size)
    }
  end
end
