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
  # Dummy worker, to perform progress/start/stop tests
  # Not used by the application, could be safely removed anytime
  #
	class DummyWorker < BaseSidekiqWorker
		sidekiq_options queue: :dummy

		def perform( seconds)
			logline "START"
			total seconds
			(0..seconds).each do |sec|
				sleep 1
				logline seconds, "Waiting [#{sec}/#{seconds}]"
				at(sec, "#{sec} second passed, #{seconds-sec} to go")
			end
			at(seconds, "#DONE. #{seconds} seconds passed.")
			logline "DONE"
		end
	end

	#
	# Dummy worker, to perform progress/start/stop tests
	# Not used by the application, could be safely removed anytime
	#
	class FindTweets < BaseSidekiqWorker
		sidekiq_options queue: :monitor, unique: :all

		def perform (hashtag=nil)
			logline "START"
			redishelper = RedisHandlerQueue.new
			ts = TwitterSearch.new

			redishelper.get_handlers.each do |handler|
				hash = eval(handler)
							binding.pry
				#Find tweets of each handler
				new_tweets = ts.search_by_hashtag(hash[:handler])
				new_tweets.each do |tweet|
					binding.pry
					#Save only new tweets
					if Tweet.find(:all,:conditions => ["tweet_id=?",tweet.id.to_s]).empty?
						logline "Added new handler #{handler}" , tweet.text
						#Save tweet and create new task related
						save_tweet tweet
						binding.pry
						args = {:name => hash[:name], :project_id => hash[:project_id],
							 :task_list_id => hash[:task_list_id],:access_token=>hash[:access_token],
							 :description =>"New task from handler #{hash[:handler]} refs to tweet #{tweet.text}"}
						response = create_redbooth_task (args)
						#TODO:parse response to get the code response!!
						if response == 200
							logline "New RedBooth task" , "Handler #{hash[:handler]}"
						else
							logline "FAILED" , "Responde Status #{response}"
						end
				
					end
				end
			end
			#Job executed each 15min or when manual launched
			self.class.perform_in(15.minutes)
			logline "DONE"
		end

		def save_tweet tweet
			Tweet.create(	:author => tweet.user.screen_name ,
							:message => tweet.text,
							:tweet_id => tweet.id.to_s		)
		end


	end

end