# twitter_example

just playing with the Twitter API and Redbooth.

Simple RoR app that take a "handler" to looking for in twitter (#something) and create a task in Redbooth periodically.

- It's used a sidekiq job to repeat the process (see config/schedule.yml and workers.rb).
- The same tweet for the same handler is not allowed.
- Redis keep alive the handlers and access_token to feedup the job.
- Access token is refresh if needed in session and redis.
- It's only valid for one project (see credentials.rb).
- Find tweets is limit to 1 per handler each time that the job is executed.
