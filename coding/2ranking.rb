
require 'uri'

require 'nokogiri'
require 'open-uri'





keywords = ARGV[0]


keywords = keywords.gsub(","," ").squeeze(" ").gsub(" ","+")

doc = Nokogiri::HTML(open("https://www.google.co.za/search?q="+keywords+"&start=00"))


urls = doc.css("h3.r")


#puts urlss.index('&amp')
#puts urls.length

def meta(x)
  elite = Nokogiri::HTML(open(x))
  
  tags_h_t = elite.css("meta").to_s
  
  startindex = tags_h_t.index('<meta name="keywords" content=')
  
  if !startindex.nil?
    tags_t = tags_h_t[startindex..-1]
    endindex = tags_t.index('>')
    tags = tags_t[31..endindex-2]
    return tags
  end
  return nil
  #tags_t = tags_h_t[tags_h_t.index('<meta name="keywords" content=')..-1]
  
  #return tags_t
  
end

ranking = 0
for i in 0..urls.length-1
  withtail = urls[i].to_s.gsub('<h3 class="r"><a href="/url?q=','')
  link = withtail[0..withtail.index('&amp')-1]
  
  if (link =~ URI::regexp) == 0
    
    puts link
    puts link =~ URI::regexp
    begin
      puts meta(link)
    rescue
      puts nil
    end
    puts "\n\n"
  end
  
end
