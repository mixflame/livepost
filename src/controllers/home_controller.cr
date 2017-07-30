class HomeController < ApplicationController
  def index
    client = Mongo::Client.new "mongodb://localhost:27017/livepost"
    db = client["live_post"]

    collection = db["boards"]

    messages = db["messages"]

    last_posted = messages.find_one({"$query" => {"name" => {"$ne" => ""}}, "$orderby": {"$natural" => 1}})

    last_posted = last_posted.nil? ? "" : last_posted["name"]

    @board_name = "home"
    render("index.ecr")
  end
end
