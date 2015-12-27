require 'nokogiri'
require 'open-uri'



doc = Nokogiri::HTML(open("https://www.google.com/search?q=labia&start=00"))

puts doc
