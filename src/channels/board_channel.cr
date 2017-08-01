class BoardChannel < Amber::WebSockets::Channel

  def handle_joined(client_socket, message)
    UserSocket.broadcast("message", "board_room:connected", "socket:connected", {"connected" => Amber::WebSockets::ClientSockets.client_sockets.size})
  end

  # def handle_leave(client_socket)
  #   puts "left"
  #   UserSocket.broadcast("message", "board_room:connected", "socket:connected", {"connected" => Amber::WebSockets::ClientSockets.client_sockets.size})
  # end

  def handle_message(msg)
    p msg
    event = msg["event"]
    topic = msg["topic"]
    subject = msg["subject"]
    if subject == "socket:connected"
      board = msg["payload"]["board"]
      UserSocket.broadcast("message", "board_room:connected", "socket:connected", {"connected" => Amber::WebSockets::ClientSockets.client_sockets.size, "this_board" => Amber::WebSockets::ClientSockets.get_subscribers_for_topic("board_room:#{board.to_s}").size})
    end
  end
end