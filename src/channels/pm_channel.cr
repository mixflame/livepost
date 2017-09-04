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
      UserSocket.broadcast("pm:message", "pm_room:#{handle}", "pm:message", {"message" => msg["payload"]["message"], "author" => msg["payload"]["author"]})
    end
  end
end