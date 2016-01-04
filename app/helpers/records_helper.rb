require 'uri'
require 'nokogiri'
require 'open-uri'
require 'net/http'

module RecordsHelper
  def sd_insert(type, element)
    sd_unit = Hash.new
    
    sd_unit["property"] = element.attribute(type)
    
    if element.attribute("content").nil?
      sd_unit["value"] = element.inner_html
    else
      sd_unit["value"] = element.attribute("content")
    end
    return sd_unit
  end
  
  def header_translate(x)
    if x=="h1"
      return "Main heading"
    elsif x=="h2"
      return "level 2 heading"
    elsif x=="h3"
      return "level 3 heading"
    elsif x=="h4"
      return "level 4 heading"
    elsif x=="h5"
      return "level 5 heading"
    elsif x=="h6"
      return "level 6 heading"
    end
  end
  def contains(x,y)
    !x[y].nil?
  end
  def find_root(x)
    if !x[8..-1].index("/").nil?
    x[0..x[8..-1].index("/")+7]
    else
    x
    end
  end 
  def url_extention(x)
    if !x[8..-1].index("/").nil?
      x[x[8..-1].index("/")+8..-1]
    else
      x
    end
  end
  def fetch(uri_str)
    response = Net::HTTP.get_response(URI(uri_str))
    case response
    when Net::HTTPSuccess then
      return uri_str
    when Net::HTTPRedirection then
      return response['location']
    else
      return nil
    end
  end
  def strip_it(x)
    x.gsub("https://","").gsub("http://","").gsub("www.","")
  end

  def sentence_style(x)
    if x.length == 1
      return x[0]
    elsif x.length == 2
      return x[0] + " and " + x[1]
    else
      multiple_words = ""
      x.each do |i|
	multiple_words = multiple_words + i + ", "
      end
      return multiple_words[0..-3]
    end
  end
  
  def microformats_checker(classes)
    classes.split.each do |i|
      if ['hatom', 'hentry', 'hfeed', 'hresume', 'hreview', 'vcalendar', 'vcard', 'vevent', 'xoxo'].include? i
	return true
      end
    end
    return false
  end
  
  def count_em(string, substring)
    string.scan(/(?=#{substring})/).count
  end
  
  def add_spaces(x)
    return " "+x
  end
  
  def analysis_one(hash, text, keywords, length_limit=1000, urll=false)
    if text.empty?
      hash["content"] = "missing!"
      hash["content_color"] = "red"
    else
      hash["content"] = text.gsub("&amp;","&")
      hash["content_color"] = "black"
    
    #text.downcase!
    client_keywords = text.downcase.split(/[, ;.&!?()\-\[\]]/).uniq.reject{|s| s.to_s == ''}

    end
    hash["keyword_presence"] = Hash.new
    keywords.each do |i|
      if urll
	hash["keyword_presence"][i] = text.downcase.include? i.downcase
      else
	begin
	hash["keyword_presence"][i] = client_keywords.include? i.downcase
	rescue
	end
      end
    end
    
    matches = 0
    hash["keyword_presence"].each do |i|
      if i[1] == true
	matches = matches+1
      end
    end	
    
    hash["coverage"] = Hash.new
    if !hash["keyword_presence"].empty?
      hash["coverage"]["value"] = (matches.to_f / hash["keyword_presence"].length * 100).round(0)
      hash["coverage"]["color"] = hash["coverage"]["value"] == 100 ? "green" : hash["coverage"]["value"] > 0 ? "amber" : "red"
    else
      hash["coverage"]["value"] = 0
      hash["coverage"]["color"] = "black"
    end

    
    if text.length == 0
      hash["length"] = "0 characters"
      hash["length_color"] = "red"
      #hash["length_comment"] = " - try keeping it under " + length_limit.to_s
    elsif text.length < length_limit
      hash["length_color"] = "green"
      hash["length"] = text.length.to_s+" characters - good length"
    else
      hash["length_color"] = "amber"
      hash["length"] = text.length.to_s+" characters - try keeping it under " + length_limit.to_s
    end
    
    return hash
  end
  
  
  def seo_anal(url, keywords)
    red = "red"
    amber = "amber"
    green = "green"
    
    keywords = keywords.gsub(","," ").squeeze(" ")
    

    $seoresult = Hash.new
    $seoresult["keywords"] = keywords.split(" ")
    
    # on the page seo
    def otpseo(x)
      start = Time.new
      pagesource = Nokogiri::HTML(open(x))
      finish = Time.new
      
      #Title
      $seoresult["title"] = Hash.new
      $seoresult["title"] = analysis_one($seoresult["title"], pagesource.css("title").inner_html, $seoresult["keywords"], 70)
      
      #meta
      metalimit = 160
      $seoresult["meta"] = Hash.new
      begin
	$seoresult["meta"] = analysis_one($seoresult["meta"], pagesource.css("meta[name=description]").attribute("content").to_s, $seoresult["keywords"], metalimit)
      rescue
	$seoresult["meta"] = analysis_one($seoresult["meta"], "", $seoresult["keywords"], metalimit)
      end
      
      #headers
      $seoresult["headers"] = Hash.new
      all_headers = pagesource.css("h1, h2, h3, h4, h5, h6")
      $seoresult["headers"]["data"] = all_headers
      all_headers_text = ""
      h1_count = 0
      heading_string = ""
      all_headers.each do |i|
	heading_string = heading_string + i.to_s[1..2]
	all_headers_text = all_headers_text + i.inner_html.to_s.gsub(/<[^>]*>/, "") + " "
	if i.to_s[1..2] == "h1"
	  h1_count = h1_count + 1
	end
      end
      
      $seoresult["headers"] = analysis_one($seoresult["headers"], all_headers_text, $seoresult["keywords"])
      
      
      #$seoresult["headers"]
      
      
      #check header scipping
      #if pagesource.css("h6").nil?
      
      
      
      #making sure there is no more than one h1
      $seoresult["headers"]["organization"] = "Your headings seem well organized"
      $seoresult["headers"]["organization_color"] = "green"
      if h1_count > 1
	$seoresult["headers"]["organization"] = "you seem to have more than one main heading (h1). We highly recommend you only use one describing the entire page"
	$seoresult["headers"]["organization_color"] = "red"
      elsif h1_count == 0
	$seoresult["headers"]["organization"] = "you are missing a main heading (h1)"
	$seoresult["headers"]["organization_color"] = "red"
      elsif contains(heading_string,"h6") & !( contains(heading_string,"h5") & contains(heading_string,"h4") & contains(heading_string,"h3") & contains(heading_string,"h2") & contains(heading_string,"h1"))
	$seoresult["headers"]["organization"] = "you have scipped to a level 6 heading (h6) prematurely"
	$seoresult["headers"]["organization_color"] = "red"
      elsif contains(heading_string,"h5") & !( contains(heading_string,"h4") & contains(heading_string,"h3") & contains(heading_string,"h2") & contains(heading_string,"h1"))
	$seoresult["headers"]["organization"] = "you have scipped to a level 5 heading (h5) prematurely"
	$seoresult["headers"]["organization_color"] = "red"
      elsif contains(heading_string,"h4") & !( contains(heading_string,"h3") & contains(heading_string,"h2") & contains(heading_string,"h1"))
	$seoresult["headers"]["organization"] = "you have scipped to a level 4 heading (h4) prematurely"
	$seoresult["headers"]["organization_color"] = "red"
      elsif contains(heading_string,"h3") & !( contains(heading_string,"h2") & contains(heading_string,"h1"))
	$seoresult["headers"]["organization"] = "you have scipped to a level 3 heading (h3) prematurely"
	$seoresult["headers"]["organization_color"] = "red"
      elsif contains(heading_string,"h2") & !contains(heading_string,"h1")
	$seoresult["headers"]["organization"] = "you have scipped to a level 2 heading (h2) prematurely"
	$seoresult["headers"]["organization_color"] = "red"
      end
      
      #structured data
      $seoresult["structure"]=Hash.new
      $seoresult["structure"]["vocab"] = Array.new
      $seoresult["structure"]["vocab_color"] = "green"
      
      
      s_d_screen = Array.new
      sd_formats = Hash.new
      sd_formats["md"] = Array.new
      sd_formats["rdfa"] = Array.new
      sd_formats["mf"] = Array.new
      sd_formats["jld"] = Array.new
      
      if !pagesource.css("script[type='application/ld+json']").empty?
	s_d_screen << "JSON-LD"
	json_ld_array = pagesource.css("script[type='application/ld+json']").to_s.sub("<script type=\"application/ld+json\">","").sub("</script>","").gsub("\\u0040","@").gsub("\"","").gsub("{","").gsub("}","").split(",")
	#sd_formats["jld"] = Hash.new
	json_ld_array.each do |i|
	  property_value_pair = Hash.new
	  property_value_pair["property"] = i.split(":")[0]
	  property_value_pair["value"] = i.split(":")[1..-1].join
	  
	  sd_formats["jld"] << property_value_pair
	  if property_value_pair["property"] == "@context"
	    $seoresult["structure"]["vocab"] << property_value_pair["value"]
	  end
	
	end
	
      end
      
      
      
      
      htmlelements =pagesource.to_s.gsub(/>[^>]*</, "><").gsub(/\="[^"]*"/,"").gsub(/<!--[^>]*-->/, "").gsub(/<\![^>]>/,"").gsub(/<\![^>]*>/,"").scan(/<[^ >]*/).map { |i| i.gsub("</","").gsub("<","") }
      htmlelements.uniq!
      
 
      atr = Array.new
      htmlelements.each do |elements|
	begin
	pagesource.css(elements).each do |singleelement|
	  
	  
	  #checking for microformats support
	  if !singleelement.attribute("class").nil?
	    if microformats_checker(singleelement.attribute("class").to_s)
	      s_d_screen << "microformats"
	      sd_formats["mf"] << singleelement
	    end
	  end
	  
	  
	  
	  #checking for RDFa support and filling in the sd_formats array
	  if !singleelement.attribute("property").nil?
	    s_d_screen << "RDFa"	    
	    sd_entry = sd_insert("property", singleelement)
	    sd_formats["rdfa"] << sd_entry
	    if sd_entry["property"].to_s.include? ":"
	      $seoresult["structure"]["vocab"] << sd_entry["property"].to_s.split(":")[0]
	    end
	  end
	  if !singleelement.attribute("resource").nil? 
	    s_d_screen << "RDFa"
	    #sd_formats["rdfa"] << sd_insert("resource", singleelement)
	  end
	  if !singleelement.attribute("prefix").nil?
	    s_d_screen << "RDFa"
	    $seoresult["structure"]["vocab"] << singleelement.attribute("prefix").to_s
	    #sd_formats["rdfa"] << sd_insert("prefix", singleelement)
	  end
	  if !singleelement.attribute("typeof").nil? 
	    s_d_screen << "RDFa"
	    #sd_formats["rdfa"] << sd_insert("typeof", singleelement)
	  end
	  if !singleelement.attribute("vocab").nil?
	    s_d_screen << "RDFa"
	    $seoresult["structure"]["vocab"] << singleelement.attribute("vocab").to_s
	    #sd_formats["rdfa"] << sd_insert("vocab", singleelement)
	  end	  
	  
	  
	  #checking for Microdata support and filling in the sd_formats array
	  if !singleelement.attribute("itemscope").nil? 
	    s_d_screen << "Microdata"
	    #sd_formats["md"] << sd_insert("itemscope", singleelement)
	  end
	  if !singleelement.attribute("itemtype").nil? 
	    s_d_screen << "Microdata"
	    $seoresult["structure"]["vocab"] << singleelement.attribute("itemtype").to_s
	    #sd_formats["md"] << sd_insert("itemtype", singleelement)
	  end
	  if !singleelement.attribute("itemid").nil? 
	    s_d_screen << "Microdata"
	    #sd_formats["md"] << sd_insert("itemid", singleelement)
	  end
	  if !singleelement.attribute("itemprop").nil?
	    s_d_screen << "Microdata"
	    sd_formats["md"] << sd_insert("itemprop", singleelement)
	  end
	  if !singleelement.attribute("itemref").nil?
	    s_d_screen << "Microdata"
	    #sd_formats["md"] << sd_insert("itemref", singleelement)
	  end
	end
	rescue
	end
      end
      $seoresult["structure"]["vocab"].uniq!
      if $seoresult["structure"]["vocab"].empty?
	$seoresult["structure"]["vocab_color"] = "amber"
      end
      s_d_screen.uniq!
      
      $seoresult["structure"]["data"] = sd_formats
      $seoresult["structure"]["content"] = ""
      if s_d_screen.empty?
	$seoresult["structure"]["content"] = "You do not seem to include any form of structured data"
	$seoresult["structure"]["color"] = "red"
      else
	$seoresult["structure"]["content"] = sentence_style(s_d_screen)
	$seoresult["structure"]["color"] = "green"
      end
      
      
      
      
      
      
      
      
      
      #stuffing
      #$seoresult["stuffing"] = Hash.new
      #$seoresult["keywords"].each do |i|
	#$seoresult["stuffing"][i] = count_em(pagesource.to_s.downcase, i.downcase)
      #end
      
      
      #images
      $seoresult["images"] = Hash.new
      images = pagesource.css("img")
      images.each do |i|
	$seoresult["images"][/[^\/]+$/.match(i.attribute("src").to_s)] = i.attribute("alt").to_s
      end

      

      #repetition
      $seoresult["repetition"] = Array.new
      super_list = Array.new
      root_url = find_root($accepted_urls[0])
      pagesource.css("a").each do |link|
	link = link.attribute("href").to_s
	
	
	
	if ((link[0,1] != "#" && link["https://"].nil? && link["http://"].nil?) || link[strip_it(x).sub(/\/.*/,"")]) && (!$accepted_urls.include?(link[0..-2]) && !$accepted_urls.include?(link) ) && link != "/" && link != "" && link["#"].nil? && link[0..1] != "//" && link["@"].nil?
	  
	  # if it ts s soomething like "http://bla.com" or "https://bla.com"
	  if !link["http://"].nil? || !link["https://"].nil?
	    link = link
	  #if ist something like "contacts.php"
	  elsif  link[0] != "/"
	    link = root_url +"/"+link
	    
	    
	  #if its something like "/Contacts.php"
	  else 
	    link = root_url + link
	  end
	  
	  link_ending=url_extention(link)
	  if !link_ending["contact"].nil? || !link_ending["about"].nil? || !link_ending["career"].nil? || !link_ending["privacy"].nil? || !link_ending["jobs"].nil? || !link_ending["shop"].nil? || !link_ending["terms"].nil? || !link_ending["conditions"].nil? || !link_ending["policy"].nil? || !link_ending["community"].nil? || !link_ending["pricing"].nil? || !link_ending["help"].nil? || !link_ending["faq"].nil? || !link_ending["press"].nil? || !link_ending["blog"].nil? || !link_ending["feedback"].nil? || !link_ending["news"].nil?
	    super_list << link
	  end
	  
	  
	  $seoresult["repetition"] << link
	end
      end
      
      
      #choose from the superlist if it exists otherwise use the normal list
      if !super_list.empty?
	$seoresult["repetition"] = super_list[0]#.uniq
	another_page = super_list[0]
      else
	$seoresult["repetition"][0]#.uniq!
	another_page = $seoresult["repetition"][0]
      end
      
      if !another_page.nil?
      
	repetition_text = "we visited another page on your site ("+another_page+") and noticed, you "
	
	#"do not repeat"
	pagesource2 = Nokogiri::HTML(open(another_page))      
	if pagesource2.css("title").inner_html == pagesource.css("title").inner_html
	  $seoresult["title"]["other"] = repetition_text+"repeat the same title"
	  $seoresult["title"]["other_color"] = "red"
	else
	  $seoresult["title"]["other"] = repetition_text+"change your title, well done"
	  $seoresult["title"]["other_color"] = "green"
	end
	
	      
	#meta uniquenesss      
	begin
	  meta_one= pagesource.css("meta[name=description]").attribute("content").to_s
	rescue
	  meta_one= ""
	end
	begin
	  meta_two= pagesource2.css("meta[name=description]").attribute("content").to_s
	rescue
	  meta_two= ""
	end
	if meta_one == meta_two
	  $seoresult["meta"]["other"] = repetition_text+"repeat the same meta tags"
	  $seoresult["meta"]["other_color"] = "red"
	else
	  $seoresult["meta"]["other"] = repetition_text+"change your meta description, well done"
	  $seoresult["meta"]["other_color"] = "green"
	end
	
	
	
      else
	no_links_text= "You dont seem to have any internal links on the page you provided, so we cant check this for you"
	$seoresult["title"]["other"] = no_links_text
	$seoresult["meta"]["other"] = no_links_text
      end
      
      #$seoresult["repetition"] = $accepted_urls.include? "https://www.facebook.com"
      
      #architecture
      
      #url
      $seoresult["url"] = Hash.new
      $seoresult["url"] = analysis_one($seoresult["url"], x, $seoresult["keywords"], 115, true)
      
      #url canonicalization
      $seoresult["url_canon"] = Hash.new
      if $accepted_urls.length > 1
	$seoresult["url_canon"]["color"] = "red"
	$seoresult["url_canon"]["content"] = "Your site can be accessed using multiple URL's ("+$accepted_urls.join(", ")+"). Search engines will treat each domain as a separate page (this is bad)! To solve the issue, redirect URL's accordingly using HTTP 301 responses (ask your web developer about this)"
      else
	$seoresult["url_canon"]["color"] = "green"
	$seoresult["url_canon"]["content"] = "very well done! all URL's redirect to "+$accepted_urls[0]
      end
      
      #speed
      $seoresult["speed"] = Hash.new
      $seoresult["speed"]["time"] = (finish - start).round(2)
      speedtip = "try reducing your amount of http requests or upgrade your server hardware"
      if $seoresult["speed"]["time"] < 2
	$seoresult["speed"]["color"] = "green"
	$seoresult["speed"]["comment"] = "your page loads fast, well done"
      elsif $seoresult["speed"]["time"] < 4
	$seoresult["speed"]["color"] = "amber"
	$seoresult["speed"]["comment"] = "your page is slow, " + speedtip
      else
	$seoresult["speed"]["color"] = "red"
	$seoresult["speed"]["comment"] = "your page is very slow, " + speedtip
      end
	
      
      #https
      $seoresult["security"] = Hash.new
      http = false
      $accepted_urls.each do |i|
	if i[0..4] == "http:"
	  http = true
	end
      end
	  
      
      
      if !http
        $seoresult["security"]["protocol"] = "HTTPS"
	$seoresult["security"]["comment"] = "you are limiting connections to HTTPS, excellent"
	$seoresult["security"]["color"] = "green"
      else
	$seoresult["security"]["protocol"] = "HTTP"
        $seoresult["security"]["comment"] = "you are currently allowing HTTP access, limiting access to HTTPS (a more secure version of the HTTP protocol) will help improve your search engine ranking"
	$seoresult["security"]["color"] = "amber"
      end
      
      
    end

    
    
    
    #URL magic
    stripped_url = strip_it(url)
    
    
    url_variations = ["http://","https://","http://www.","https://www."]
    
    #url_variations2 = ["http://","http://www."]
    
    $accepted_urls = Array.new
    
    res_array = Array.new
    
    url_variations.each do |i|
      begin
	url_string = i+stripped_url
	url = URI.parse(url_string)
	req = Net::HTTP.new(url.host, url.port)
	req.use_ssl = (url.scheme == 'https')
	path = url.path if url.path.present?
	res = req.request_head(path || '/')
	res_array << url.to_s
	if res.code == "200"
	  $accepted_urls << url_string
	end
      rescue
      end
    end
    
    #execute if all URL redirect or if the URL does not exist
    if $accepted_urls.empty?
      #if URL does not exits
      if res_array.empty?
	return res_array
      end
      #Find redirections
      redirections = Array.new
      res_array.each do |i|
	redirections << fetch(i)
      end
      return redirections.uniq
    end
    
    #ensuring url if formatted correctly and if not then we try to connect with http and if that fails we try https
    otpseo($accepted_urls[0])

    
    return $seoresult


  end
end
