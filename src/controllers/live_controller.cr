class LiveController < ApplicationController

    def livestagram
        @board_name = "home"
        client = Mongo::Client.new "mongodb://localhost:27017/livepost"
        db = client["live_post"]
        messages = db["messages"]
        render("livestagram.ecr")
    end

end
