


require 'nokogiri'
require 'open-uri'
require 'iconv'




keywords = ARGV[0]
url =  ARGV[1]

url = url.gsub("www.","").gsub("https://","").gsub("http://","")
keywords = keywords.gsub(","," ").squeeze(" ").gsub(" ","+")

doc = Nokogiri::HTML(open("https://www.google.co.za/search?q="+keywords+"&start=00"))
#doc = File.open("nokodata") { |f| Nokogiri::XML(f) }


#puts doc
def clean(x)
  rs = x.gsub('<cite>','').gsub('</cite>','').gsub("<b>","").gsub("</b>","").gsub("www.","").gsub("https://","").gsub("http://","")
  if rs[-1,1].eql? "/"
    return rs[0..-2]
  end
  return rs
end

def cleanmeta(x)
  #x.gsub('<span class="st">','').gsub('</span>','').gsub('<b>','').gsub('</b>','').gsub('<br>','').gsub('.','').gsub(',','').gsub('-',' ').gsub(';','').gsub('&amp;','').gsub('|','').gsub("\u00A0",'').gsub("("," ").gsub(")",' ').to_s.gsub(/[^0-9A-Za-z]/, ' ')
  #x.gsub(/[^0-9A-Za-z]/, ' ')
  x = x.encode!(Encoding::UTF_8)
  x.force_encoding(Encoding::UTF_8).gsub(/\W/, ' ')#.parameterize#.to_s.gsub(/[^A-Za-z]/, ' ')
end


selist = Hash.new
selist[0] = doc.css("div.s").css("cite")
selist[1] = doc.css("div.s").css("span.st")



for i in 0..selist[0].length-1
  puts clean(selist[0][i].to_s) + "\n" + cleanmeta(selist[1][i].to_s) + "\n\n"
end


p keywords

p url

p "hell o".gsub(/[^0-9A-Za-z]/, '')
p "hi89".gsub(/[^A-Za-z]/, ' ').squeeze(" ")

p "fsdj fklj3 9fdsd0 fsd*((".parameterize
#p cleanmeta(selist[1][1].to_s)
