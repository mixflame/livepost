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
    if subject == "post:new"
      message = msg["payload"]["message"]
      author = msg["payload"]["author"]
      board = msg["payload"]["board"]
      image = msg["payload"]["image"]
      rebroadcast!({"event" => event, "topic" => topic, "subject" => subject, "payload" => {"message" => HTML.escape(message.to_s), "author" => HTML.escape(author.to_s), "board" => board.to_s, "image" => image.to_s}})
    elsif subject == "board:new"
      board = msg["payload"]["board"]
      rebroadcast!({"event" => event, "topic" => topic, "subject" => subject, "payload" => {"board" => HTML.escape(board.to_s)}})
    elsif subject == "post:increment"
      board = msg["payload"]["board"]
      author = msg["payload"]["author"]
      rebroadcast!({"event" => event, "topic" => topic, "subject" => subject, "payload" => {"board" => board.to_s.gsub(" ", "-"), "author" => HTML.escape(author.to_s)}})
    elsif subject == "socket:connected"
      UserSocket.broadcast("message", "board_room:connected", "socket:connected", {"connected" => Amber::WebSockets::ClientSockets.client_sockets.size})
    end
  end
end