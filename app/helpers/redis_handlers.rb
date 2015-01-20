module RedisHandlers
	HANDLERS = 'queue_handlers'

	class RedisHandlerQueue

		# Enqueu a new handler in Redis to be able by workers
		# args => Hash = {:project_id=>"12", :handler=>"cr7", :task_list_id=>"32",:access_token=>"xxxxxxxx"}
		def enqueu_handler args
			unless self.include? args
				REDIS.lpush(HANDLERS,args)
				return true
			else
				return false
			end
		end

		# Return handler in Redis
		def get_handlers
			REDIS.lrange(HANDLERS,0,REDIS.llen(HANDLERS))
		end

		#Helper to dont allow the same handler twice.
		def include? args
			get_handlers.each do |handler|
				hash = eval(handler)
				next if hash[:handler].nil?
				return true if (hash[:handler] == args[:handler])
			end
			return false
		end

		def remove_all
			REDIS.del(HANDLERS)
		end

	end

end