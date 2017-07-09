class HomeController < ApplicationController
  def index
    client = Mongo::Client.new "mongodb://localhost:27017/livepost"
    db = client["live_post"]

    collection = db["boards"]

    @board_name = "home"
    render("index.ecr")
  end
end

