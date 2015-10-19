# Artist Info.
# It is common in "mp3" and "Karaoke" info

class Artist
  def initialize(name,url)
    @name = name
    @url = url
    @mp3_count = 0
    @karaoke_count = 0
    @f_favorite = false
    @d_lastsang = nil
  end
  attr_accessor :name, :url, :mp3_count, :karaoke_count, :f_favorite, :d_lastsang
end
