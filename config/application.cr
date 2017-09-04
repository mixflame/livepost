AMBER_ENV = ARGV[0]? || ENV["AMBER_ENV"]? || "development"
APP_PATH = __FILE__

# Amber::Server.instance.session = {
#   :key     => "livepost.session",
#   :store   => :signed_cookie,
#   :expires => 0,
#   :secret  => "ANDvuadpv!!!uwap9*Yva98wuaw98euawve"
# }

Amber::Server.configure do |app|
  # Server options
  app_path = __FILE__ # Do not change unless you understand what you are doing.
  app.name = "LivePost web application."
  app.port = (ENV["PORT"] ||= "3000").to_i # Port you wish your app to run
  app.env = (ENV["AMBER_ENV"] ||= "development").to_s
  app.log = ::Logger.new(STDOUT)
  app.log.level = ::Logger::INFO
  if(app.env == "production")
    # acquire these with cerbot certonly standalone
    app.ssl_key_file = "/home/mixflame/livepost/config/privkey.pem"
    app.ssl_cert_file = "/home/mixflame/livepost/config/fullchain.pem"
  end
end
