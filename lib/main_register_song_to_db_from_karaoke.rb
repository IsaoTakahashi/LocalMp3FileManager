#! ruby -Ku
# encoding: utf-8

require 'restclient'
require 'nokogiri'
require 'sequel'

require_relative 'enum/searchwordtype'
require_relative 'enum/searchmatchtype'
require_relative 'karaokeSearch'


DB = Sequel.sqlite('db/mp3_kara.sqlite')

mp3files = DB[:mp3files]
karaoke_songs = DB[:karaoke_songs]

# i = 3

mp3files.all.each do |song|
    song_title_mp3 = song[:title]
    next if song.size < 1

    result = KaraokeSearch.search(song_title_mp3,
                                SearchWordType::SONG,
                                SearchMatchType::COMPLETE_MATCH)

    result_table = result.xpath('//div[@id="showsMusicTable"]')
    song_nodes = result_table.css('table').css('tr')
    p '------------------------------------------'
    if song_nodes
        p song_title_mp3 + ':' + ((song_nodes.count - 1) / 2).to_s
        song_nodes.each do |node|

            # get title info
            title_node = node.xpath('td[@class="title"]')
            next unless title_node.size > 0
            song_title_karaoke = title_node.inner_text.strip
            gakkyoku_id = title_node.css('a').attribute('href').value.match(/gakkyokuId=(\d+)/)[1]

            # get artist info
            singer_node = node.xpath('td[@class="singer"]')[0].css('p').css('a')
            artist_name_karaoke = singer_node.inner_text.strip
            artist_path = singer_node.attribute('href').value
            artist_id = artist_path.match(/artistId=(\d+)/)[1]
            p artist_name_karaoke + ' : artistId=' + artist_id + ', gakkyokuId=' + gakkyoku_id

            karaoke_songs.insert(:gakkyoku_id => gakkyoku_id,
                                 :artist_id => artist_id,
                                 :title_karaoke => song_title_karaoke,
                                 :title_mp3 => song_title_mp3,
                                 :artist_name_karaoke => artist_name_karaoke,
                                 :artist_name_mp3 => song[:artist])
        end
    else
        p song_title_mp3 + ' : 0件'
    end

    # i = i-1
    # break unless i > 0

end
