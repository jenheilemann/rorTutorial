# Load the rails application
require File.expand_path('../application', __FILE__)

# loading up the app config file
config_file = Rails.root.join('config', 'app_config.yml')
APP_CONFIG = YAML.load_file(config_file)[Rails.env] if File.exists?(config_file)

# Initialize the rails application
SampleApp::Application.initialize!
