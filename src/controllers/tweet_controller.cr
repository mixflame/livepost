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
            "tweet" => params["tweet"].to_s
        })

        {error: "Successfully posted tweet.", csrf: csrf_tag}.to_json
    end
end
