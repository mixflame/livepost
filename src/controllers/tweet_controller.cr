class TweetController < ApplicationController
    def create_tweet
        client = Mongo::Client.new "mongodb://localhost:27017/livepost"
        db = client["live_post"]
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

        tweets = db["tweets"]
        tweets.insert({
            "author" => params["author"].to_s,
            "tweet" => params["tweet"].to_s[0..139] # 140 chars
        })

        UserSocket.broadcast("message", "tweet_room:tweets", "tweet:new", {:tweet => HTML.escape(params["tweet"]), :author => HTML.escape(params["author"])})

        {error: "Successfully posted tweet.", csrf: csrf_tag}.to_json
    end

    def follow_handle
        if params["following"] == "anonymous" || params["following"] == ""
            return {error: "Anonymous can't follow a handle."}.to_json
        end
        if params["followed"] == "anonymous"
            return {error: "Can't follow anonymous"}.to_json
        end
        client = Mongo::Client.new "mongodb://localhost:27017/livepost"
        db = client["live_post"]
        followings = db["followings"]
        followings.insert({"followed" => params["followed"], "following" => params["following"]})
        {error: "success", csrf: csrf_tag}.to_json
    end

    def home
        @board_name = "home"
        client = Mongo::Client.new "mongodb://localhost:27017/livepost"
        db = client["live_post"]
        tweets = db["tweets"]
        followings = db["followings"]
        render("home.ecr")
    end
end
