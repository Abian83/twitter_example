class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string  :hashtag
      t.integer :project_id
      t.integer :task_list_id
      t.integer :task_id
      t.string  :description
      t.string  :name
      t.integer :user_id

      t.timestamps
    end
  end
end
