class OauthController < ApplicationController

	require 'oauth2'
	require 'json'
	include RedboothHelper

	def index
		@authorize_link =  get_redirect_link_redbooth
	end

	def authorize
		client = OAuth2::Client.new(@client_id, @client_secret, :site => @site)
		client.options[:authorize_url] = @authorize_url
		client.auth_code.authorize_url(:redirect_uri => @redirect_uri)
	end


	def callback
		session[:code] = params[:code]
		redirect_to :controller => 'tweets', :action => 'index', :code => session[:code]
	end


end
