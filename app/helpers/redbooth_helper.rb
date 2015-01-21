module RedboothHelper
	include RedisHandlers

	CLIENT_ID     = "3be91f77979d438886038bdf0aec18725508ba5493486c6b0cbcd7f92cd91372"
	CLIENT_SECRET = "3b0d221425033e2e9e70c042bf278f91c6169412518543ec83d7bfde35e821c7"
	REDIRECT_URI  = "http://localhost:3030/oauth/callback"
	SITE          = "https://redbooth.com/oauth2/authorize"
	AUTHORIZE_URL = "/oauth2/authorize"
	TOKEN_URL	  = "/oauth2/token"
	POST_TASK_URI = "https://redbooth.com/api/3/tasks"
	GET_PROJECTS_URI  = "https://redbooth.com/api/3/projects"
	GET_TASK_LIST_URI = "https://redbooth.com/api/3/task_lists"
	REFRESH_TOKEN_URL = "https://redbooth.com/oauth2/token"
	ERROR = 400

	def authorize_redbooth
		begin
		client = OAuth2::Client.new(CLIENT_ID, CLIENT_SECRET, :site => SITE)
		client.options[:token_url] = TOKEN_URL
		access_token = client.auth_code.get_token(session[:code], :redirect_uri => REDIRECT_URI	)
		#Save token on session
		session[:access_token] = access_token.token
		session[:refresh_token] = access_token.refresh_token
		rescue OAuth2::Error => exception
			#refresh
			if exception.code == "invalid_grant"
				response = refreh_token
				unless response == ERROR
					data = JSON.parse(response)
					old_access_token = session[:access_token]
					session[:access_token]  = data["access_token"]
					session[:refresh_token] = data["refresh_token"]
					binding.pry
					#TODO: refresh access_token in redis!!
					redishelper = RedisHandlerQueue.new
					redishelper.update_tokens_in_redis(old_access_token,session[:access_token],session[:refresh_token])
				end
				ERROR
			end
		end
		
	end

	def get_redirect_link_redbooth
		client = OAuth2::Client.new(CLIENT_ID, CLIENT_SECRET, :site => SITE)
		client.options[:authorize_url] = AUTHORIZE_URL
		client.auth_code.authorize_url(:redirect_uri => REDIRECT_URI)
	end
	
	def refreh_token
		begin
			response_json = RestClient.post REFRESH_TOKEN_URL , {
					:client_id       => CLIENT_ID,
					:client_secret   => CLIENT_SECRET,
					:refresh_token  => session[:refresh_token],
					:grant_type     => "refresh_token",
			}
		rescue RestClient::Unauthorized => exception
			ERROR
		end

	end

	def create_redbooth_task args
		begin
			response_json = RestClient.post POST_TASK_URI , {
					:access_token => args[:access_token],
					:project_id   => args[:project_id],
					:task_list_id => args[:task_list_id],
					:name         => args[:name],
					:description  => args[:description],
			}
			response_json
			
		rescue RestClient::BadRequest => exception
			ERROR
		end
		

	end

	def get_redbooth_projects args
		begin
			response_json = RestClient.get GET_PROJECTS_URI ,{:params => {
				:access_token => args[:access_token],:order => "id",:archived => false}}
			if response_json.code == 200
				JSON.parse(response_json)
			else
				authorize_redbooth	
			end
		rescue RestClient::InternalServerError => exception
		end
	end

	def get_redbooth_task_lists args
		begin
			response_json = RestClient.get GET_TASK_LIST_URI ,{:params => {:access_token => args[:access_token],
				:order => "id",:archived => false}}
		    if response_json.code == 200
				JSON.parse(response_json)
			else
				authorize_redbooth	
			end
		rescue RestClient::InternalServerError => exception
		end
	end



end