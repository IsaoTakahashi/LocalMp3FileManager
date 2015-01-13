#! ruby -Ku
# encoding: utf-8

require 'nokogiri'
require 'open-uri'
require 'sequel'

DB = Sequel.sqlite('db/mp3_kara.sqlite')

karaoke_crawled_songs = DB[:karaoke_crawled_songs]


# target url
url = "http://joysound.com/ex/search/song.htm?gakkyokuId="

# min and max id count
id_min = 260001
id_max = 300000

charset = 'utf-8'

p "Start from " + id_min.to_s

for i in id_min..id_max

	p i if i%100 == 0

    id = i.to_s
    html = nil

    begin
        html = open(url+id)
    rescue Exception => e
        #p id + " may not be found."
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

    karaoke_crawled_songs.insert(:gakkyoku_id => i,
                                :artist_id => artist_id,
                                :title_karaoke => song_title,
                                :artist_name_karaoke => artist_name)
end
