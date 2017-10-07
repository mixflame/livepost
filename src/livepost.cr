# LivePost by Jonathan Silverman aka Anya Summer Meadow
# For Seminole, Osage, Arapahoe, Dylan, Jessie, Rachel, Thomas. For Life. To the bullet. Amen.

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

# reset online handles (or they will stick)
client = Mongo::Client.new "mongodb://localhost:27017/livepost"
db = client["live_post"]
collection = db["online_nicks"]
collection.remove({"name" => {"$ne" => ""}})

amber = Amber::Server

if amber.settings.env == "production"
  puts "production mode. daemonizing."
  Daemonize.daemonize(stdout: "/home/mixflame/livepost/production.log", stderr: "/home/mixflame/livepost/error.log", stdin: "/dev/null")
end

amber.instance.run
