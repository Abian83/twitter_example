class Tweet < ActiveRecord::Base
  attr_accessible :author, :message, :tweet_id
end
