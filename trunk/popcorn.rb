#!/usr/bin/ruby -w

require 'rubygems'

URL = "http://imdb.com/title/tt0084827/"


class Imdb 

  IMDB_URI = "imdb.com"
  IMDB_LOC = "/title/"

  def initialize( url=nil )
    get_url( url ) 
  end

  def url( url=nil )
    get_url( url ) unless url == nil
    @url
  end

  alias url= url

  def get_url( url )
    @url = url.split( /\// ).pop unless url == nil
  end

  def fetch
    require 'net/http'
    content = Net::HTTP.get_response( IMDB_URI, IMDB_LOC + @url + "/" ) 
    @content = content.body
  end
 
  def parse
    @info = []

    @info << {"Title" => @content.scan( /"title">\s*(.*)\s*<small/ )[0].to_s }

    @info << {"Year"  => @content.scan( /"title">.*(\d{4})<\/a>\)/ )[0].to_s }

    @info << {"Directed by" =>
                 @content.scan( /Directed by.*\n.*">(.*)<\/a/ )[0].to_s }
    
    genre = @content.scan( /Genre:<\/b>\n(.*)/ ).to_s.split("/") 
    genre.collect!{ |g| g.scan( /">(.*)</ )[0].to_s }
    genre = genre.delete_if{ |x| (x == "") or (x == "(more)") }
    @info << {"Genre" =>  genre }

    @info << {"Tagline" => @content.scan( /Tagline:<\/b>(.*)<a/ )[0].to_s.strip }

    @info << {"Plot Outline" => @content.scan( /Outline:<\/b>(.*)<a.*summary/ )[0].to_s.strip }

    @info << {"Rating" => @content.scan( /<b>(.*)<\/b>.*votes\)/ )[0].to_s }
   
    cast = @content.scan( /Cast overview(.*)/ )[0].to_s.split("=")
    cast.collect!{ |g| g.scan( /">(.*)<\/a/ )[0].to_s }
    cast = cast.delete_if{ |x| (x == "") or (x == "(more)") }
    @info << {"Cast" => cast }

    @info << {"Runtime" => @content.scan( /Runtime:<\/b>\n(.*)/ )[0].to_s }
    #p @info
  end

  def desc
    fetch
    parse

    @info.each do |desc|
      key = desc.keys.to_s
      if desc.values.class == [].class 
        values = desc.values.flatten
        last_element = values.pop
        value = values.collect!{ |x| x + ", " }.to_s + last_element
      else
        value = desc.values
      end

      values = desc.values
      print "#{key}: \t" + (key.length > 5 ? "" : "\t") + "#{value} \n" unless value.empty?
      print "--------------------------------------------------\n" if key == "Title"
    end
  end
  
  private :get_url, :fetch, :parse
end

print "\n\n"
#print "Fetching #{URL} ...\n"

movie = Imdb.new

movie.url = STDIN.gets.strip
movie.desc

print "\n\n"
#print "Fetching tt0121766 ...\n"

#movie.url = "tt0121766"
#movie.desc

#print "\n\n"
#print "Fetching http://imdb.com/title/tt0395699/ ...\n"


#movie.url = "http://imdb.com/title/tt0395699/"
#movie.desc
