#! ruby -Ku
# encoding: utf-8

require 'restclient'
require 'nokogiri'
require 'sequel'

require_relative 'enum/searchwordtype'
require_relative 'enum/searchmatchtype'
require_relative 'karaokeSearch'


DB = Sequel.sqlite('db/mp3_kara.sqlite')

artists = DB[:artists]
karaoke_artists = DB[:karaoke_artists]

i = 3

artists.all.each do |artist|
    artist_name = artist[:name]
    next if artist.size < 1

    result = KaraokeSearch.search(artist_name,
                                SearchWordType::ARTIST,
                                SearchMatchType::COMPLETE_MATCH)

    singer_nodes = result.xpath('//td[@class="singer"]')
    if singer_nodes
        p artist[:name] + ' : ' + singer_nodes.count.to_s + '件'
        singer_nodes.each do |node|
            artist_path = node.css('a').attribute('href').value
            artist_id = artist_path.match(/artistId=(\d+)/)[1]
            p 'http://joysound.com/ex/search/artist.htm?artistId=' + artist_id

            karaoke_artists.insert(:name => artist[:name], :artist_id => artist_id)
        end
    else
        p artist[:name] + ' : 0件'
    end

    i = i-1
    break unless i > 0

end
