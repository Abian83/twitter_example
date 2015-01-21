include Twitter_Api
include RedisHandlers
include RedboothHelper

require 'oauth2'
	
module Workers

	FIXNUM_MAX = (2**(0.size*8-2)-1)

	class BaseSidekiqWorker
		include Sidekiq::Worker
		include Sidekiq::Status::Worker
		sidekiq_retry_in{|count| FIXNUM_MAX}

		def logline(*args)
			puts "[<< #{Time.now} >> #{self.class} @ #{@jid} ] "+args.join(" | ")
		end
	end

	#
	# 
	# This Job is executed like a crontask and when is launched manually
	# see config/schedule.yml for cron information.
	#
	class FindTweets < BaseSidekiqWorker
		sidekiq_options queue: :monitor, unique: :all

		def perform (hashtag=nil)
			logline "START"
			redishelper = RedisHandlerQueue.new
			ts = TwitterSearch.new

			redishelper.get_handlers.each do |handler|
				hash = eval(handler)
				#Find tweets of each handler
				new_tweets = ts.search_by_hashtag(hash[:handler])
				new_tweets.each do |tweet|
					#Save only new tweets
					if Tweet.find(:all,:conditions => ["tweet_id=?",tweet.id.to_s]).empty?
						logline "Added new handler #{handler}" , tweet.text
						#Save tweet and create new task related
						save_tweet tweet
						args = {:name => hash[:name] + " | " + Time.now.to_s, :project_id => hash[:project_id],
							 :task_list_id => hash[:task_list_id],:access_token=>hash[:access_token],
							 :description =>"New task from handler #{hash[:handler]} refs to tweet #{tweet.text}"}
						response = create_redbooth_task (args)

						#TODO:parse response to get the code response!!
						if response.code == 201
							logline "New RedBooth task" , "Handler #{hash[:handler]}"
						else
							#Try to authorize again if expired
							authorize_redbooth
							logline "FAILED" , "Responde Status #{response}"
						end
				
					end
				end
			end
			logline "DONE"
		end

		def save_tweet tweet
			Tweet.create(	:author => tweet.user.screen_name ,
							:message => tweet.text,
							:tweet_id => tweet.id.to_s		)
		end


	end

end