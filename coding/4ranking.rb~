require 'uri'
require 'nokogiri'
require 'open-uri'

keywords = ARGV[0]
$url = ARGV[1]
keywords = keywords.gsub(","," ").squeeze(" ").gsub(" ","+")
doc = Nokogiri::HTML(open("https://www.google.co.za/search?q="+keywords+"&start=00"))
urls = doc.css("h3.r")

def meta(x)
  begin
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
  rescue
    return nil
  end  
end


def steralize(x)
  x = x.sub('www.','').sub('http://','').sub('https://','')
  if x[-1,1] == '/'
    return x[0..-2]
  else
    return x
  end
  #end
  #return x[0..-2]
end

def compare(selink)
  selink = steralize(selink)
  userlink = steralize($url)
  if userlink['/']
    puts "houston we have a problem"
    return  selink == userlink
  else
    return  selink == userlink
  end
  
  #puts selink
  #puts userlink
  #return  selink == userlink
end

ranking = 0
for i in 0..urls.length-1
  withtail = urls[i].to_s.gsub('<h3 class="r"><a href="/url?q=','')
  link = withtail[0..withtail.index('&amp')-1]
  
  if (link =~ URI::regexp) == 0
    ranking = ranking+1
    puts link
    if compare(link)
      break
    end
    #puts meta(link)
    puts "\n\n"
  end
  
end

puts ranking
