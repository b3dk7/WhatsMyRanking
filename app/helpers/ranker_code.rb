def rank_it(url, keywords)
    keywords = keywords.gsub(","," ").squeeze(" ").gsub(" ","+")
    result = Hash.new
    result["rank"]=0
    result["url"]=""
    counter = 0
    rank = 0
    found = false
    for i in 0..15

        if found
          break
        end
        

        doc = Nokogiri::HTML(open("https://www.google.com/search?q="+keywords+"&start="+i.to_s+"0"))
        listing = doc.css("li.g")
        urls = listing.css("h3.r")

        


        for i in 0..urls.length-1
          withtail = urls[i].to_s.sub('<h3 class="r"><a href="/url?q=','')
          link = URI::decode(withtail[0..withtail.index('&amp')-1])
          setitle = urls[i].css("a").to_s
          setitle = setitle[setitle.index('">')+2..-1].gsub("&amp;","").sub("</a>","").gsub("<b>","").gsub("</b>","")
          if (link =~ URI::regexp) == 0
            counter = counter+1
            
            #if counter < 11
            #otpseo(link)
            #else
            puts link
            #end
            #puts setitle
            if link[url.downcase.sub("www.","").sub("http://","").sub("https://","")]
              found = true
              rank = counter
              $se_found_url = link
              break
            end
          end
          
          
          if !doc.css("p#ofr").empty?
            
            break
            
          end
        end
        if rank > 0
          returnstr = $se_found_url + " is ranked number " + rank.to_s
          
        else
          returnstr =  "sorry we could not find you"
        end
      end
    
  end