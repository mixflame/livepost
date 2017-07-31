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
    p params
    client = Mongo::Client.new "mongodb://localhost:27017/livepost"
    db = client["live_post"]

    collection = db["messages"]

    if collection.count({"message" => {"$eq" => HTML.escape(params["message"])}, "name" => {"$eq" => params["board_name"]} }) == 0 && ((params["image"].size / 1024) < 350)
      collection.insert({ "name" => params["board_name"], "message" => HTML.escape(params["message"]), "author" => HTML.escape(params["author"]), "image" => params["image"], "timestamp" => Time.now.to_s })
      {board: params["board_name"], message: params["message"], author: params["author"], image: params["image"], csrf: csrf_tag}.to_json
    else
      {error: "Already posted this or image too big.", csrf: csrf_tag}.to_json
    end
  end

  def delete_board
    @board_name = URI.unescape(params["name"])
    render("delete_board.ecr")
  end

  def remove_board
    client = Mongo::Client.new "mongodb://localhost:27017/livepost"
    db = client["live_post"]

    collection = db["boards"]

    messages = db["messages"]

    password = collection.find_one({"$query" => {"name" => {"$eq" => params["board_name"]}}})
    password = password.nil? ? "" : password["password"]
    if(params["password"] == ENV["LIVEPOST_PASSWORD"]) # admin
      collection.remove({"name" => params["board_name"]})
      messages.remove({"name" => params["board_name"]})
      return "deleted"
    elsif(params["password"] == password && password != "")
      collection.remove({"name" => params["board_name"]})
      messages.remove({"name" => params["board_name"]})
      return "deleted"
    else
      return "not deleted (incorrect password)"
    end
  end
end
