#! ruby -Ku
# encoding: utf-8

require_relative 'fileSearch'
require_relative 'entities/mp3file'
require 'mp3info'

dir_list_path = File.dirname(__FILE__) + "/assets/dir.lst"

dir_lst = FileSearch.get_dir_list(dir_list_path)
dir_lst.each do |dir_path|
	p dir_path
	files = FileSearch.search_mp3(dir_path)

	files.each do |file|
		stat = File.stat(file)
		Mp3Info.open(file){ |mp3|
			artist = Mp3File.new(file,File.basename(file),mp3.tag.artist,mp3.tag.title,mp3.tag.album,File.mtime(file))
			p artist
		}
	end
end