file = File::stat("demo/FileSearch.rb")
p file.mtime.to_s

dir_path = "."
files = Dir.glob(dir_path + "/**/*.mp3")
p files.count