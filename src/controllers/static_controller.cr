class StaticController < ApplicationController
  def index
    "do nothing"
  end
  def slug
    # board page
    client = Mongo::Client.new "mongodb://localhost:27017/livepost"
    db = client["live_post"]

    collection = db["messages"]
    @board_name = URI.unescape(params["slug"])

    render("board.ecr")
  end
end