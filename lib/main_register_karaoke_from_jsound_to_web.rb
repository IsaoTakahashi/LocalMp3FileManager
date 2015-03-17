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


# target url
url = "http://joysound.com/ex/search/song.htm?gakkyokuId="

# min and max id count
id_min = 750000
id_max = 760000

#ids = Array(id_min..id_max)

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

    id = i.to_s
    html = nil

    begin
        html = open(url+id)
    rescue Exception => e
        p e
        next
    end

    doc = Nokogiri::HTML.parse(html, nil, charset)

    song_title = doc.title.gsub('：カラオケ楽曲検索｜JOYSOUND.com','')
    artist_nodes = doc.xpath('//td[@class="artist"]')

    next unless artist_nodes.size > 0

    artist_node = artist_nodes[0].css('p').css('a')
    artist_name = artist_node.inner_text

    artist_id = artist_node.attribute('href').value.match(/artistId=(\d+)/)[1]

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
