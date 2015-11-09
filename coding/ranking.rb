


require 'nokogiri'
require 'open-uri'
require 'iconv'


doc = Nokogiri::HTML(open("https://www.google.co.za/search?q=print+cape+town&start=00"))
#doc = File.open("nokodata") { |f| Nokogiri::XML(f) }


#puts doc
def clean(x)
  x.gsub('<cite>','').gsub('</cite>','').gsub("<b>","").gsub("</b>","").gsub("www.","")
end

def cleanmeta(x)
  x.gsub('<span class="st">','').gsub('</span>','').gsub('<b>','').gsub('</b>','').gsub('<br>','').gsub('.','').gsub(',','').gsub('-',' ').gsub(';','').gsub('&amp;','').gsub('|','').gsub("\u00A0",'')   # \u00A0#.encode('UTF-8', :invalid => :replace, :undef => :replace)
end


selist = Hash.new
selist[0] = doc.css("div.s").css("cite")
selist[1] = doc.css("div.s").css("span.st")
#selist[0].each{ |x| puts clean(x.to_s) }

p cleanmeta(selist[1][0].to_s).encoding

for i in 0..selist[0].length-1
  puts clean(selist[0][i].to_s) + "\n" + cleanmeta(selist[1][i].to_s) +"\n\n"
end



#p cleanmeta(selist[1][1].to_s)
