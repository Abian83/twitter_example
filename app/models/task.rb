class Task < ActiveRecord::Base
  attr_accessible :description, :hashtag, :name, :project_id, :task_id, :task_list_id, :user_id
end
