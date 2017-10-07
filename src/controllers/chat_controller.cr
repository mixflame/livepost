class ChatController < ApplicationController
  def chatroom
    @board_name = ""
    client = Mongo::Client.new "mongodb://localhost:27017/livepost"
    db = client["live_post"]
    collection = db["online_nicks"]
    chat_messages = db["chat_messages"]
    render("chatroom.ecr")
  end

  def send_message
    message = HTML.escape(params["message"])[0..512]
    UserSocket.broadcast("message", "chat_room:chat", "message:new", {:author => HTML.escape(session[:handle].to_s), :message => message})
    client = Mongo::Client.new "mongodb://localhost:27017/livepost"
    db = client["live_post"]
    chat_messages = db["chat_messages"]
    chat_messages.insert({"message" => message, "author" => HTML.escape(session[:handle].to_s)})
    response.content_type = "text/json"
    {error: "Success", csrf: csrf_tag}.to_json
  end
end
