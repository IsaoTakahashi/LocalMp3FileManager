#! ruby -Ku
# encoding: utf-8

require 'nokogiri'
require 'open-uri'
require 'sequel'
require 'restclient'

def post_karaoke_song(json)
    begin
        result = RestClient.post 'http://127.0.0.1:9393/karaoke', json,  :content_type => :json
        result = RestClient.post 'http://ec2-54-92-60-143.ap-northeast-1.compute.amazonaws.com/karaoke', json,  :content_type => :json
        #p result
    rescue Exception => e
        p e
    end
    result
end

DB = Sequel.sqlite('db/mp3_kara.sqlite')

karaoke_crawled_songs = DB[:karaoke_crawled_songs]

# min and max id count
id_min = 750000
id_max = 900000

charset = 'utf-8'

p "Start from " + id_min.to_s
karaoke_array = []

for i in id_min..id_max

    # check index to send new data to web
    if i%100 == 0 then
        p i
        if karaoke_array.size > 0 then
            p karaoke_array
            post_karaoke_song(karaoke_array.to_json)
            karaoke_array = []
        end
    end

    # check target id data is already exists
    target = karaoke_crawled_songs.where(:gakkyoku_id => i)
    if !target.empty? then
        target.each do |song|
            p song[:gakkyoku_id] + ' - ' + song[:title_karaoke] + ': already exists'
        end
        next
    end

    sleep(0.5)

    id = i.to_s
    url = 'https://mspxy.joysound.com/Common/ContentsDetail?kind=songId&selSongNo=' + i.to_s + '&interactionFlg=0&apiVer=1.0'

    result = nil
    begin
        result = RestClient.post url, nil, {:content_type => 'application/x-www-form-urlencoded;charset=UTF-8', 'X-JSP-APP-NAME' => '0000800'}
    rescue Exception => e
        p 'Error: ' + id
        p e
        next
    end

    json_result = JSON.parse(result)
    song_title = json_result['songName']
    artist_name = json_result['artistInfo']['artistName']
    artist_id = json_result['artistInfo']['artistId']

    p id + " -- " + artist_name + " | " + song_title

    # insert new data
    karaoke_crawled_songs.insert(:gakkyoku_id => i,
                                 :artist_id => artist_id,
                                 :title_karaoke => song_title,
                                 :artist_name_karaoke => artist_name)
    # create json
    karaoke_params = {}
    karaoke_params[:song_id] = i
    karaoke_params[:artist_id] = artist_id
    karaoke_params[:song_title] = song_title
    karaoke_params[:artist_name] = artist_name

    karaoke_array << karaoke_params
end

# upload remain songs
if karaoke_array.size > 0 then
    p karaoke_array
    post_karaoke_song(karaoke_array.to_json)
    karaoke_array = []
end

# refresh search keyword
result = RestClient.get 'http://ec2-54-92-60-143.ap-northeast-1.compute.amazonaws.com/karaoke/search/refresh'
