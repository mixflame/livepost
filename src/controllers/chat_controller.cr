class ChatController < ApplicationController
  def chatroom
    @board_name = ""
    render("chatroom.ecr")
  end

  def send_message
    UserSocket.broadcast("message", "chat_room:chat", "message:new", {:author => HTML.escape(session[:handle].to_s), :message => HTML.escape(params["message"])})
    response.content_type = "text/json"
    {error: "Success", csrf: csrf_tag}.to_json
  end
end
