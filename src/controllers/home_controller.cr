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

  def register_handle
    render("register_handle.ecr")
  end

  def register_handle_post
    client = Mongo::Client.new "mongodb://localhost:27017/livepost"
    db = client["live_post"]

    collection = db["handles"]

    password = collection.find_one({"$query" => {"name" => {"$eq" => params["handle"]}}})
    password = password.nil? ? "" : password["password"]

    if collection.find_one({"name" => params["handle"]}).nil? && password == ""
        collection.insert({ "name" => params["handle"], "password" => params["password"]})
        session[:handle] = params["handle"]
        {error: "registered", csrf: csrf_tag}.to_json
    elsif !password.nil? && password == params["password"]
        session[:handle] = params["handle"]
        {error: "logged in", csrf: csrf_tag}.to_json
    else
        {error: "handle already exists", csrf: csrf_tag}.to_json
    end
  end
end
