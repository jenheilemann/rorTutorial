# Load the rails application
require File.expand_path('../application', __FILE__)

# loading up the app config file
config_file = Rails.root.join('config', 'app_config.yml')
if File.exists?(config_file)
  YAML.load_file(config_file)[Rails.env].each { |k,v| ENV[k] = v }
end

# Initialize the rails application
SampleApp::Application.initialize!
