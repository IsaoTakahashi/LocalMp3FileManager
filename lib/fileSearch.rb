class FileSearch
	class << self
		def get_dir_list(lst_path)
			dirs = []
			File.open(lst_path, 'r:utf-8') do |f|
				f.each_line do |line|
					dirs.push(line.strip)
				end
			end
			dirs
		end

		def search_mp3(dir_path)
			files = Dir.glob(dir_path + "/**/*.mp3")
			files.count
		end
	end
end
