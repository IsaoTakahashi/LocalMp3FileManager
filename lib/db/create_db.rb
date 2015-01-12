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
    String :d_created
    Integer :size
end

DB.create_table :karaoke_artists do
    primary_key :id
    String :name
    String :artist_id
end

DB.create_table :karaoke_songs do
    primary_key :id
    String :gakkyoku_id
    String :artist_id
    String :title_karaoke
    String :title_mp3
    String :artist_name_karaoke
    String :artist_name_mp3
end
