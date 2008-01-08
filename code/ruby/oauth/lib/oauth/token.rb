require 'oauth/key'
module OAuth
  
  # Superclass for the various tokens used by OAuth
  
  class Token
    include OAuth::Key
    
    attr_accessor :token, :secret

    def initialize(token, secret)
      @token = token
      @secret = secret
    end
    
    def to_query
      "oauth_token=#{escape(token)}&oauth_secret=#{escape(secret)}"
    end
    
  end
  
  # Used on the server for generating tokens
  class ServerToken<Token
    
    def initialize
      super generate_key(16),generate_key
    end
  end
  # Superclass for tokens used by OAuth Clients
  class ConsumerToken<Token
    attr_accessor :consumer

    def initialize(consumer,token,secret)
      super token,secret
      @consumer=consumer
    end
    
    # Make a signed request using given http_method to the path
    def request(http_method,path,*arguments)
      response=consumer.request(http_method,path,self,*arguments)
    end
    
    # Sign a request generated elsewhere using Net:HTTP::Post.new or friends
    def sign!(request,options = {})
      consumer.sign!(request,self,options)
    end
    
  end

  # The RequestToken is used for the initial Request.
  # This is normally created by the Consumer object.
  class RequestToken<ConsumerToken
    
    # Returns the authorization url that you need to use for redirecting the user
    def authorize_url
      consumer.authorize_url+"?oauth_token="+CGI.escape(token)
    end
    
    # exchange for AccessToken on server
    def get_access_token(options={})
      response=consumer.token_request(consumer.http_method,consumer.access_token_path,self,options)
      OAuth::AccessToken.new(consumer,response['oauth_token'],response['oauth_token_secret'])
    end
  end
  
  # The Access Token is used for the actual "real" web service calls thatyou perform against the server
  class AccessToken<ConsumerToken
    
    def get(path,headers={})
      request(:get,path,headers)
    end
    
    def head(path,headers={})
      request(:head,path,headers)
    end

    def post(path, body = '',headers={})
      request(:post,path,body,headers)
    end

    def put(path, body = '', headers={})
      request(:put,path,body,headers)
    end
    
    def delete(path,headers={})
      request(:delete,path,headers)
    end
  end
end
