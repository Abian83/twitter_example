include Twitter_Api

module Workers

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
		sidekiq_options queue: :task

		def perform hashtag
			logline "START"

			ts = TwitterSearch.new
			new_tweets = ts.search_by_hashtag(hashtag)

			new_tweets.each do |tweet|
				#Save only new tweets
				if Tweet.find(:all,:conditions => ["tweet_id=?",tweet.id.to_s]).empty?
					logline tweet.text
					t = Tweet.new
					t.author    = tweet.user.screen_name
					t.message   = tweet.text
					t.tweet_id  = tweet.id
					t.save
				end
			end
			self.class.perform_in(10.minutes.ago)
			logline "DONE"
		end
	end

end