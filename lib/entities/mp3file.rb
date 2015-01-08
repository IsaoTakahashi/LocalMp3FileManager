# To change this template, choose Tools | Templates
# and open the template in the editor.

class Mp3File
  def initialize(pat,fil,art,tit,alb,dat)
    @file_path = pat
    @file_name = fil
    @artist = art
    @title = tit
    @album = alb
    @date = dat
  end

  def show_simple
    puts "Artist: " + @artist + " | Title: " + @title
  end

  attr_accessor :file_path,:file_name, :artist,:title,:album,:date
end
