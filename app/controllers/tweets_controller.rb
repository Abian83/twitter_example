class TweetsController < ApplicationController
  include Twitter_Api
  include RedisHandlers
  require 'rest_client'


  # GET /tweets
  # GET /tweets.json
  def index

    @tweets = Tweet.limit(50)
    @no_authorized = false


    if params[:code]
      session[:code] = params[:code]
    end
    
    #Get access_token
    if session[:access_token].nil? || params[:code]
      if authorize_redbooth == ERROR
        @no_authorized = true
      end
    end

    begin
      args = {:access_token => session[:access_token]}
      response   = get_redbooth_projects (args)
      @projects = response.map{|x| [x["name"],x["id"]]} if response
      response = get_redbooth_task_lists (args) 
      @task_lists = response.map{|x| [x["name"],x["id"]]} if response
    rescue RestClient::Unauthorized => exception
      if authorize_redbooth == ERROR 
        @no_authorized = true
      end
    end



    if @no_authorized
      redirect_to :controller => 'oauth', :action => 'index' and return
    else
      redishelper = RedisHandlerQueue.new
      @handlers = redishelper.get_handlers

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @tweets }
      end
    end
  
  end


  # GET /search
  # GET /search.json
  def search
    redishelper = RedisHandlerQueue.new
    #Push handler in redis
    @errors = []
    args = {:name         => params[:name],
            :access_token => session[:access_token],
            :refresh_token=> session[:refresh_token],
            :project_id   => params[:project_id],
            :task_list_id => params[:task_list_id],
            :handler      => params[:hashtag],}

    if redishelper.enqueu_handler (args)
      Workers::FindTweets.perform_async
    else
      @errors << "Something was wrong trying to enqueu handler in Redis"
    end
    redirect_to action: :index
  end 

  def remove_all_jobs
    redishelper = RedisHandlerQueue.new
    redishelper.remove_all
    render :index
  end



  # GET /tweets/1
  # GET /tweets/1.json
  def show
    @tweet = Tweet.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @tweet }
    end
  end

  # GET /tweets/new
  # GET /tweets/new.json
  def new
    @tweet = Tweet.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @tweet }
    end
  end

  # GET /tweets/1/edit
  def edit
    @tweet = Tweet.find(params[:id])
  end

  # POST /tweets
  # POST /tweets.json
  def create
    @tweet = Tweet.new(params[:tweet])

    respond_to do |format|
      if @tweet.save
        format.html { redirect_to @tweet, notice: 'Tweet was successfully created.' }
        format.json { render json: @tweet, status: :created, location: @tweet }
      else
        format.html { render action: "new" }
        format.json { render json: @tweet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tweets/1
  # PUT /tweets/1.json
  def update
    @tweet = Tweet.find(params[:id])

    respond_to do |format|
      if @tweet.update_attributes(params[:tweet])
        format.html { redirect_to @tweet, notice: 'Tweet was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @tweet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tweets/1
  # DELETE /tweets/1.json
  def destroy
    @tweet = Tweet.find(params[:id])
    @tweet.destroy

    respond_to do |format|
      format.html { redirect_to tweets_url }
      format.json { head :no_content }
    end
  end
end
