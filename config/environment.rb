# config/environment.rb

require_relative "application"

require "devise"

Rails.autoloaders.main.ignore("/rails/lib") if Rails.respond_to?(:autoloaders)

# Initialize the Rails application.
Rails.application.initialize!
