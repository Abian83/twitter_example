class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.string :message
      t.string :tweet_id
      t.string :author

      t.timestamps
    end
  end
end
