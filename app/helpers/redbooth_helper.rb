module RedboothHelper

	CLIENT_ID     = "3be91f77979d438886038bdf0aec18725508ba5493486c6b0cbcd7f92cd91372"
	CLIENT_SECRET = "3b0d221425033e2e9e70c042bf278f91c6169412518543ec83d7bfde35e821c7"
	REDIRECT_URI  = "http://localhost:3030/oauth/callback"
	SITE          = "https://redbooth.com/oauth2/authorize"
	AUTHORIZE_URL = "/oauth2/authorize"
	TOKEN_URL	  = "/oauth2/token"
	POST_TASK_URI = "https://redbooth.com/api/3/tasks"
	GET_PROJECTS_URI  = "https://redbooth.com/api/3/projects"
	GET_TASK_LIST_URI = "https://redbooth.com/api/3/task_lists"

	def authorize_redbooth
		client = OAuth2::Client.new(CLIENT_ID, CLIENT_SECRET, :site => SITE)
		client.options[:token_url] = TOKEN_URL
		access_token = client.auth_code.get_token(session[:code], :redirect_uri => REDIRECT_URI	)
		session[:access_token] = access_token.token
		session[:refresh_token] = access_token.refresh_token
		
	end

	def get_code_redbooth
		client = OAuth2::Client.new(CLIENT_ID, CLIENT_SECRET, :site => SITE)
		client.options[:authorize_url] = AUTHORIZE_URL
		redirect_to client.auth_code.authorize_url(:redirect_uri => REDIRECT_URI)
	end

	def create_redbooth_task args
		response_json = RestClient.post POST_TASK_URI , {
				:access_token => args[:access_token],
				:project_id   => args[:project_id],
				:task_list_id => args[:task_list_id],
				:name         => args[:name],
				:description  => args[:description],
		}
		response_json
	end

	def get_redbooth_projects args
		response_json = RestClient.get GET_PROJECTS_URI ,{:params => {:access_token => args[:access_token]}}
		if response_json.code == 200
			JSON.parse(response_json)
		else
			authorize_redbooth	
		end
	end

	def get_redbooth_task_lists args
		response_json = RestClient.get GET_TASK_LIST_URI ,{:params => {:access_token => args[:access_token],:order => "id"}}
	    if response_json.code == 200
			JSON.parse(response_json)
		else
			authorize_redbooth	
		end
	end

end