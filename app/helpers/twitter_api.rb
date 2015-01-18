module Twitter_Api

#load 'app/helpers/twitter_api.rb'
# => 



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
        config.consumer_key        = self.oauth[:CONSUMER_KEY]
        config.consumer_secret     = self.oauth[:CONSUMER_SECRET]
        config.access_token        = self.oauth[:ACCESS_TOKEN]
        config.access_token_secret = self.oauth[:ACCESS_TOKEN_SECRET]
      end
    end

    #Max 8days before
    def search_by_hashtag (tag , args={})
      #client.search("#ronaldo", :lang => "es" , :until => "2015-01-09",:result_type => "recent").marge(args)
      #self.session.search(tag, args).take(3).collect do |tweet|
      #  puts "#{tweet.user.screen_name}: #{tweet.text}"
      #end
      self.session.search(tag, args).take(3)
    end

    #t = client.search("#ronaldo", :lang => "es" , :until => "2015-01-09").take(3)




  end




end
#Worker en Redis que se ejecute cada hora y busque los tweets de cada hashtag.

#Mongo guardar los hashtag de tareas a crear y los tweets previamente leidos
# [mongoid_tweets] - [response_new_tweets] = real_new_tweets.

#Con esto crear la tarea en redbooth