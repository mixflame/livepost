require "mongo"
require "amber"
require "daemonize"
require "./sockets/**"
require "./channels/**"
require "./controllers/**"
require "./jobs/**"
require "./mailers/**"
require "./models/**"
require "./views/**"
require "../config/*"


amber = Amber::Server.instance

if amber.env == "production"
  puts "production mode. daemonizing."
  Daemonize.daemonize
end

amber.run