require 'sequel'

DB = Sequel.sqlite('mp3_kara.sqlite')

DB.create_table :artists do
	primary_key :id
	String :name
	String :url
	Integer :mp3_count
	Integer :karaoke_count
	Boolean :f_favorite
	Date :d_lastsang
end

DB.create_table :mp3files do
	primary_key :id
	String :file_path
	String :file_name
	String :artist
	String :title
	String :album
	String :d_get
	Integer :size
end