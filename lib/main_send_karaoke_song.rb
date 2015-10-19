#! ruby -Ku
# encoding: utf-8

require 'sequel'
require 'restclient'

def post_karaoke_song(json)
    begin
        result = RestClient.post 'http://ec2-54-65-104-20.ap-northeast-1.compute.amazonaws.com/karaoke', json,  :content_type => :json
        #p result
    rescue Exception => e
        p e
    end
end

DB = Sequel.sqlite('db/mp3_kara.sqlite')

karaoke_crawled_songs = DB[:karaoke_crawled_songs]

# 100を1とする
unit_idx = 100
start_idx = 3001 #36400件登録済み
end_idx = 3930

for i in start_idx..end_idx
    start_id = i * unit_idx + 1
    end_id = start_id + unit_idx - 1

    p "#{start_id} to #{end_id}"

    test_set = karaoke_crawled_songs.order(:id).limit(start_id..end_id)

    start_time = Time.now
    p "Start from #{start_time}"

    karaoke_array = []

    test_set.each do |karaoke|
        karaoke_params = {}
        karaoke_params[:song_id] = karaoke[:gakkyoku_id]
        karaoke_params[:artist_id] = karaoke[:artist_id]
        karaoke_params[:song_title] = karaoke[:title_karaoke]
        #karaoke_params[:song_title_search] = karaoke[:title_karaoke]
        karaoke_params[:artist_name] = karaoke[:artist_name_karaoke]
        #karaoke_params[:artist_name_search] = karaoke[:artist_name_karaoke]
        #p karaoke_params
        #p karaoke
        #post_karaoke_song(karaoke_params.to_json)
        karaoke_array << karaoke_params
    end

    #p karaoke_array.to_json
    post_karaoke_song(karaoke_array.to_json)
    #p result

    end_time = Time.now
    p "Finished at #{end_time}"
    p "Process Tims is #{end_time - start_time} [sec]"

end

# json = RestClient.get 'http://127.0.0.1:9393/karaokes.json'
# p json
