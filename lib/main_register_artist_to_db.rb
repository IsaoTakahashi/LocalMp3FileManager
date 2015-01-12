#! ruby -Ku
# encoding: utf-8

require 'sequel'

DB = Sequel.sqlite('db/mp3_kara.sqlite')

# get tables
mp3files = DB[:mp3files]
artists = DB[:artists]

artist_names = mp3files.group_and_count(:artist).order(Sequel.desc(:count))

artist_names.each do |ar|
    artists.insert(:name => ar[:artist],
                 :mp3_count => ar[:count])
end
