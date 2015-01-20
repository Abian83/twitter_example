module Twitter_Api

  class TwitterSearch
    attr_accessor :oauth,
                  :session

    def initialize 
      @oauth = {
          :CONSUMER_KEY             => "dmXEZjEQYbPgKXV1rR0NRjUhp",
          :CONSUMER_SECRET          => "7krgQ7yKl3eeAunOLWU4PTUGT476cy3qYa5II3jgulLQCViR3N",
          :ACCESS_TOKEN             => "1918294964-xrneWdHdmllPxQIL7NGlPlGDTipt44RdYUmFmW3",
          :ACCESS_TOKEN_SECRET      => "2yP7Agsqe0y6DVFFvb3TGFMLixbGtxWy4ZKN7FUDMBXAl"
      }
      self.sign_in
      super
    end

    def sign_in
      @session = Twitter::REST::Client.new do |config|
        config.consumer_key        = @oauth[:CONSUMER_KEY]
        config.consumer_secret     = @oauth[:CONSUMER_SECRET]
        config.access_token        = @oauth[:ACCESS_TOKEN]
        config.access_token_secret = @oauth[:ACCESS_TOKEN_SECRET]
      end
    end

    #Max 8days before
    def search_by_hashtag (tag , args={})
      #client.search("#ronaldo", :lang => "es" , :until => "2015-01-09",:result_type => "recent").marge(args)
      #self.session.search(tag, args).take(3).collect do |tweet|
      #  puts "#{tweet.user.screen_name}: #{tweet.text}"
      #end
      self.session.search(tag, args).take(1)
    end


  end

end