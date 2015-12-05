class Record < ActiveRecord::Base
  #acts_as_textcaptcha :api_key => 'eaf450085c15c3b880c66d0b78f2c041'
  #acts_as_textcaptcha :api_key     => 'bdbf3bd1f43581ce008144fba8a41436',
                    #  :bcrypt_salt => '$2a$10$X7J5RelKiAsJPHVUuWBqOe',
		      
  acts_as_textcaptcha :api_key => 'bdbf3bd1f43581ce008144fba8a41436'
  
  
  validates :url, presence: true
  validates :keywords, presence: true
  validate  :url_regex
  
  def perform_textcaptcha?
    false
  end

  private

  def compute_ranking
    
    self.ranking = 22
  end
  
  
 #massive DOS defence!!!!! think twice about removing
 def url_regex
    if url.match(/whatsmyranking.com\/records\/.*/)
      errors.add :url, "This URL is blocked"
    end
  end
  

end




    
    
    
     
