require "mongo"
require "amber"
require "daemonize"
require "markdown"
require "./sockets/**"
require "./channels/**"
require "./controllers/**"
require "./jobs/**"
require "./mailers/**"
require "./models/**"
require "./views/**"
require "../config/*"

amber = Amber::Server

if amber.settings.env == "production"
  puts "production mode. daemonizing."
  Daemonize.daemonize(stdout: "/home/mixflame/livepost/production.log", stderr: "/home/mixflame/livepost/error.log", stdin: "/dev/null")
end

amber.instance.run
