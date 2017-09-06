class PmChannel < Amber::WebSockets::Channel

  def handle_joined(client_socket, message)
    # UserSocket.broadcast("message", "board_room:connected", "socket:connected", {"connected" => Amber::WebSockets::ClientSockets.client_sockets.size})
  end

  # def handle_leave(client_socket)
  #   puts "left"
  #   UserSocket.broadcast("message", "board_room:connected", "socket:connected", {"connected" => Amber::WebSockets::ClientSockets.client_sockets.size})
  # end

  def handle_message(client_socket, msg)
    p msg
    event = msg["event"]
    topic = msg["topic"]
    subject = msg["subject"]
    if subject == "pm:message"
      handle = msg["payload"]["handle"]
      client = Mongo::Client.new "mongodb://localhost:27017/livepost"
      db = client["live_post"]
      collection = db["handles"]
      handle_exists = collection.count({"name" => {"$eq" => msg["payload"]["handle"].to_s}}) > 0
      if handle_exists
        UserSocket.broadcast("pm:message", "pm_room:#{handle}", "pm:message", {"message" => msg["payload"]["message"], "author" => msg["payload"]["author"]})
      else
        UserSocket.broadcast("pm:message", "pm_room:#{msg["payload"]["author"]}", "pm:message", {"message" => "Specified handle does not exist.", "author" => "system"})
      end
    end
  end
end