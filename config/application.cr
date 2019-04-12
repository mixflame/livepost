APP_PATH = __FILE__

# require "./initializers/**"
require "amber"

# load the application_controller before controllers which depend on it
require "../src/controllers/application_controller"
require "../src/controllers/**"

# NOTE: Settings should all be in config/environments/env.yml.
# Anything here will overwrite all environments.
Amber::Server.configure do |setting|
  # Server options
  setting.name = "LivePost web application."
  setting.port = 3000 # Port you wish your app to run
  setting.host = "0.0.0.0"
end
