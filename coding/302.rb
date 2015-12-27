require "net/http"
require 'active_support'



#url = URI.parse("http://www.google.com/")
#req = Net::HTTP.new(url.host, url.port)


url_string = "http://freebay.fr"
url = URI.parse(url_string)
req = Net::HTTP.new(url.host, url.port)
req.use_ssl = (url.scheme == 'https')

path = url.path if url.path.present?
res = req.request_head(path || '/')
#res.code != "404" # false if returns 404 - not found
puts res.code
