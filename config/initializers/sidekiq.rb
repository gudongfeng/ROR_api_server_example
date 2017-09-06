# config/initializers/sidekiq.rb
Sidekiq.configure_server do |config|
	config.average_scheduled_poll_interval = 2
end

# for docker
# sidekiq_config = { url: ENV['JOB_WORKER_URL'] }
# for localhost
sidekiq_config = { url: "redis://localhost:6379/0" }


Sidekiq.configure_server do |config|
  config.redis = sidekiq_config
end

Sidekiq.configure_client do |config|
  config.redis = sidekiq_config
end