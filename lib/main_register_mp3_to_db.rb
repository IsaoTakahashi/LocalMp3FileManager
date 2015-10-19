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
  	p file
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

      mp3File = Mp3File.new(file,
                            File.basename(file),
                            @artist_name,
                            @title,
                            @album,
                            File.ctime(file),
                            File.size(file))
      p mp3File.artist + " | " + mp3File.title
      next if mp3files.filter(:file_path => file).all.count >= 1


      mp3files.insert(:file_path => mp3File.file_path,
                      :file_name => mp3File.file_name,
                      :artist => sanitize_string(mp3File.artist),
                      :title => sanitize_string(mp3File.title),
                      :album => sanitize_string(mp3File.album),
                      :d_created => mp3File.d_created,
                      :size => mp3File.size)
    }
  end
end
