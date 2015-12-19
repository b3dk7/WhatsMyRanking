class Record < ActiveRecord::Base
  acts_as_textcaptcha :api_key => 'bdbf3bd1f43581ce008144fba8a41436'
  validates :url, presence: true
  #validates :keywords, presence: true
  validate  :url_regex
  
  def perform_textcaptcha?
    false
  end

  private  
 #massive DOS defence!!!!! do not remove code below
 def url_regex
    if url.downcase.match(/whatsmyranking.com\/records\/.*/) || url.downcase.match(/46\.101\.115\.155\/records\/.*/) || url.downcase["localhost"]
      errors.add :url, "This URL is blocked"
    end
  end
  

end




    
    
    
     
