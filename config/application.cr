AMBER_ENV = ARGV[0]? || ENV["AMBER_ENV"]? || "development"
APP_PATH  = __FILE__

Amber::Server.configure do |app|
  # Server options
  app_path = __FILE__ # Do not change unless you understand what you are doing.
  app.name = "LivePost web application."
  app.port = 3000
  app.host = "0.0.0.0"
  app.env = (ENV["AMBER_ENV"] ||= "development").to_s
  app.log = ::Logger.new(STDOUT)
  app.log.level = ::Logger::INFO
end
