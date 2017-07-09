class BoardController < ApplicationController
  def create_board
    client = Mongo::Client.new "mongodb://localhost:27017/livepost"
    db = client["live_post"]

    collection = db["boards"]

    if collection.count({"name" => {"$eq" => params["board_name"]}}) == 0
      collection.insert({ "name" => params["board_name"], "password" => params["password"] })
      {board: params["board_name"], csrf: csrf_tag}.to_json
    else
      {error: "Not unique", csrf: csrf_tag}.to_json
    end
  end

  def create_post
    client = Mongo::Client.new "mongodb://localhost:27017/livepost"
    db = client["live_post"]

    collection = db["messages"]

    if collection.count({"message" => {"$eq" => HTML.escape(params["message"])}}) == 0
      collection.insert({ "name" => params["board_name"], "message" => HTML.escape(params["message"]), "author" => HTML.escape(params["author"]) })
      {board: params["board_name"], message: params["message"], author: params["author"], csrf: csrf_tag}.to_json
    else
      {error: "Already posted this.", csrf: csrf_tag}.to_json
    end
  end
end
