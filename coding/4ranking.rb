require 'uri'
require 'nokogiri'
require 'open-uri'

keywords = ARGV[0]
$url = ARGV[1]
keywords = keywords.gsub(","," ").squeeze(" ").gsub(" ","+")


def meta(x)
  begin
    elite = Nokogiri::HTML(open(x))
    
    tags_h_t = elite.css("meta").to_s
    
    startindex = tags_h_t.index('<meta name="description" content=')
    
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
  begin
    if selink.downcase[$url.downcase]
      return true
    else
      return false
    end
  rescue
    if selink[$url]
      return true
    else
      return false
    end
  end
  #selink = steralize(selink)
  #userlink = steralize($url)
  #if userlink['/']
   # puts "houston we have a problem"
    #return  selink == userlink
  #else
   # return  selink == userlink
  #end
  
  #puts selink
  #puts userlink
  #return  selink == userlink
end

counter = 0
rank = 0
found = false

for i in 0..30

  if found
    break
  end
  
  doc = Nokogiri::HTML(open("https://www.google.com/search?q="+keywords+"&start="+i.to_s+"0"))
  listing = doc.css("li.g")
  urls = listing.css("h3.r")

  


  for i in 0..urls.length-1
    withtail = urls[i].to_s.gsub('<h3 class="r"><a href="/url?q=','')
    link = URI::decode(withtail[0..withtail.index('&amp')-1])
    setitle = urls[i].css("a").to_s
    setitle = setitle[setitle.index('">')+2..-1].gsub("&amp;","").sub("</a>","").gsub("<b>","").gsub("</b>","")
    if (link =~ URI::regexp) == 0
      counter = counter+1
      puts link
      if counter < 11
        puts "title: "
        puts "meta keywords: "
        puts "meta description: "
        puts "<h1>: "
        puts "alt: "
      end
      #puts setitle
      if compare(link)# || compare(setitle)
        found = true
        rank = counter
        break
      end
      #puts meta(link)
      #puts "\n\n"
    end
  end
  
  if !doc.css("p#ofr").empty?
    
    break
    
  end
  puts "were on"+ counter.to_s

end


if rank > 0
  puts "you are ranked number " + rank.to_s
else
  puts "sorry you currently are not ranked on this search engine"
end

