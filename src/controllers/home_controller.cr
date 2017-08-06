class HomeController < ApplicationController

  def index
    puts context.session.to_h
    client = Mongo::Client.new "mongodb://localhost:27017/livepost"
    db = client["live_post"]

    collection = db["boards"]

    messages = db["messages"]

    last_posted = messages.find_one({"$query" => {"timestamp" => {"$ne" => ""}}, "$orderby": {"timestamp" => -1}})

    last_posted_author = last_posted.nil? ? "" : last_posted["author"]

    last_posted = last_posted.nil? ? "" : last_posted["name"]

    @board_name = "home"
    render("index.ecr")
  end
end
