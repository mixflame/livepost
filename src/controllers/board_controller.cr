class BoardController < ApplicationController
  def create_board
    client = Mongo::Client.new "mongodb://localhost:27017/livepost"
    db = client["live_post"]

    collection = db["boards"]

    raise "empty board" if params["board_name"].to_s.blank?

    response.content_type = "text/json"
    if collection.count({"name" => {"$eq" => params["board_name"]}}) == 0 && params["board_name"].size < 50
      ip_hash = OpenSSL::Digest.new("SHA256").update(request.host.to_s).to_s
      collection.insert({"name"     => params["board_name"],
                         "password" => params["password"],
                         "ip_hash"  => ip_hash})
      UserSocket.broadcast("message", "board_room:boards", "board:new", {:board => HTML.escape(params["board_name"])})
      {board: params["board_name"], csrf: csrf_tag}.to_json
    else
      {error: "Not unique or name over 50 characters.", csrf: csrf_tag}.to_json
    end
  end

  def create_post
    client = Mongo::Client.new "mongodb://localhost:27017/livepost"
    db = client["live_post"]

    collection = db["messages"]
    handles = db["handles"]

    handle = handles.find_one({"name" => params["author"]})

    if !handle.nil?
      password = handles.find_one({"$query" => {"name" => {"$eq" => params["author"]}}})
      password = password.nil? ? "" : password["password"]
      if password != params["password"]
        puts "bad password"
        return {error: "bad password", csrf: csrf_tag}.to_json
      end
    end

    raise "empty message" if params["message"].to_s.blank? && params["image"].to_s == "CYQwLiBcA0Q"

    message = Markdown.to_html(HTML.escape(params["message"]))
    response.content_type = "text/json"
    if collection.count({"message" => {"$eq" => message}, "name" => {"$eq" => params["board_name"]}, "image" => {"$eq" => params["image"]}}) == 0 && ((params["image"].size / 1024) < 5000 && params["message"].to_s.size < 2000)
      ip_hash = OpenSSL::Digest.new("SHA256").update(request.host.to_s).to_s
      collection.insert({"name" => params["board_name"],
                         "message" => message,
                         "author" => HTML.escape(params["author"]),
                         "image" => params["image"], "timestamp" => Time.now.to_s,
                         "password" => params["password"],
                         "ip_hash" => ip_hash})
      UserSocket.broadcast("message", "board_room:#{params["board_name"]}", "post:new", {:board => HTML.escape(params["board_name"]), :message => message, :author => HTML.escape(params["author"]), :image => params["image"]})
      UserSocket.broadcast("message", "board_room:home", "post:increment", {:board => HTML.escape(params["board_name"]), :author => HTML.escape(params["author"])})
      {board: params["board_name"], message: message, author: params["author"], image: params["image"], csrf: csrf_tag}.to_json
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
    response.content_type = "text/json"
    if (params["password"] == ENV["LIVEPOST_PASSWORD"]) # admin
      collection.remove({"name" => params["board_name"]})
      messages.remove({"name" => params["board_name"]})
      {error: "deleted", csrf: csrf_tag}.to_json
    elsif (params["password"] == password && password != "")
      collection.remove({"name" => params["board_name"]})
      messages.remove({"name" => params["board_name"]})
      {error: "deleted", csrf: csrf_tag}.to_json
    else
      {error: "not deleted (incorrect password)", csrf: csrf_tag}.to_json
    end
  end

  def delete_post
    @id = URI.unescape(params["id"])
    render("delete_post.ecr")
  end

  def remove_post
    client = Mongo::Client.new "mongodb://localhost:27017/livepost"
    db = client["live_post"]

    collection = db["boards"]

    messages = db["messages"]

    password = collection.find_one({"$query" => {"name" => {"$eq" => params["board_name"]}}})
    password = password.nil? || !password.has_key?("password") ? "" : password["password"]
    # change to find by id
    post_password = messages.find_one({"$query" => {"_id" => {"$eq" => BSON::ObjectId.new(params["id"])}}})
    post_password = post_password.nil? || !post_password.has_key?("password") ? "" : post_password["password"]
    response.content_type = "text/json"
    if (params["password"] == ENV["LIVEPOST_PASSWORD"])            # admin
      messages.remove({"_id" => BSON::ObjectId.new(params["id"])}) # change to use id
      {error: "deleted", csrf: csrf_tag}.to_json
    elsif (params["password"] == password && password != "")
      messages.remove({"_id" => BSON::ObjectId.new(params["id"])}) # change to use id
      {error: "deleted", csrf: csrf_tag}.to_json
    elsif (params["password"] == post_password && post_password != "")
      messages.remove({"_id" => BSON::ObjectId.new(params["id"])}) # change to use id
      {error: "deleted", csrf: csrf_tag}.to_json
    else
      {error: "not deleted (incorrect password)", csrf: csrf_tag}.to_json
    end
  end

  def update_socket_count
    board = params["board"]
    UserSocket.broadcast("message", "board_room:connected", "socket:connected", {"connected" => Amber::WebSockets::ClientSockets.client_sockets.size, "this_board" => Amber::WebSockets::ClientSockets.get_subscribers_for_topic("board_room:#{board.to_s}").size})
    response.content_type = "text/json"
    {success: "true"}.to_json
  end

  def ban_hash
    hash = params["hash"].to_s
    render("ban_hash.ecr")
  end

  def commit_ban_hash
    # admins only
    if (params["password"] != ENV["LIVEPOST_PASSWORD"])
      return {error: "bad password", csrf: csrf_tag}.to_json
    end

    client = Mongo::Client.new "mongodb://localhost:27017/livepost"
    db = client["live_post"]

    collection = db["banned_hashes"]

    collection.insert({"ip_hash" => params["ip_hash"]})

    response.content_type = "text/json"
    {error: "banned", csrf: csrf_tag}.to_json
  end

  def unban_hash
    client = Mongo::Client.new "mongodb://localhost:27017/livepost"
    db = client["live_post"]

    collection = db["banned_hashes"]
    render("unban_hash.ecr")
  end

  def commit_unban_hash
    # admins only
    if (params["password"] != ENV["LIVEPOST_PASSWORD"])
      return {error: "bad password", csrf: csrf_tag}.to_json
    end

    client = Mongo::Client.new "mongodb://localhost:27017/livepost"
    db = client["live_post"]

    collection = db["banned_hashes"]

    collection.remove({"ip_hash" => params["ip_hash"]})

    response.content_type = "text/json"
    {error: "unbanned", csrf: csrf_tag}.to_json
  end

  def change_topic
    client = Mongo::Client.new "mongodb://localhost:27017/livepost"
    db = client["live_post"]

    collection = db["boards"]

    messages = db["messages"]

    password = collection.find_one({"$query" => {"name" => {"$eq" => params["board_name"]}}})
    password = password.nil? || !password.has_key?("password") ? "" : password["password"]

    response.content_type = "text/json"
    if password == "" || params["password"] == password || password == ENV["LIVEPOST"]
      redis = Redis.new
      redis.set(params["board_name"].to_s, params["topic"].to_s)
      {error: "topic changed", csrf: csrf_tag}.to_json
    else
      {error: "topic not changed. invalid password?", csrf: csrf_tag}.to_json
    end
  end

  def handles
    client = Mongo::Client.new "mongodb://localhost:27017/livepost"
    db = client["live_post"]

    collection = db["handles"]

    handles = [] of String

    collection.find({"name" => {"$ne" => ""}}) do |handle|
      handles << handle["name"].to_s
    end

    response.content_type = "text/json"
    handles.to_json
  end
end
