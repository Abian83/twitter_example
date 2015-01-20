class Api::V1::TasksController < ApplicationController
  

  def handler
    response = {:success => false}
    if params.has_key?(:handler) && params.has_key?(:project_id) && params.has_key?(:task_list_id) && params.has_key?(:access_token)

      hl = HandlerList.new
      unless hl.include? params[:handler]
        hl.push_handler clean_params
        Workers::FindTweets.perform_async
        response[:message] = "New job added with the handler #{params[:handler]}"
        response[:success] = true
      else
        response[:message] = "Handler #{params[:handler]} already taken"
      end
    else
      response[:message] = "Params requires project_id, handler, task_list_id and access_token"
    end

    render json: response
  end


private 

  def clean_params
    {:handler => params[:handler] ,
     :project_id => params[:handler] ,
     :task_list_id => params[:task_list_id],
     :access_token => params[:access_token]}
  end

end
