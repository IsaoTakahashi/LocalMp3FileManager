#! ruby -Ku
# encoding: utf-8

require_relative 'fileSearch'


dir_list_path = File.dirname(__FILE__) + "/assets/dir.lst"

dir_lst = FileSearch.get_dir_list(dir_list_path)
dir_lst.each do |dir_path|
	p dir_path
	FileSearch.search_mp3(dir_path)
end