require 'nokogiri'
require 'open-uri'



doc = Nokogiri::HTML(open("http://www.christmasmarkets.com/UK/Leeds-christmas-market.html"))

puts doc
