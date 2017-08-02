class StaticController < ApplicationController
  def index
    "do nothing"
  end
  def slug
    # board page
    client = Mongo::Client.new "mongodb://localhost:27017/livepost"
    db = client["live_post"]

    boards = db["boards"]

    collection = db["messages"]
    @board_name = URI.unescape(params["slug"])

    if boards.find_one({"name" => @board_name}).nil?
      return "invalid board"
    end

    last_posted = collection.find_one({"$query" => {"timestamp" => {"$ne" => ""}}, "$orderby": {"timestamp" => -1}})

    last_posted_author = last_posted.nil? ? "" : last_posted["author"]

    last_posted = last_posted.nil? ? "" : last_posted["name"]

    session["test"] = "test"
    render("board.ecr")
  end
end