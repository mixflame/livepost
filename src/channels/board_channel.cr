class BoardChannel < Amber::WebSockets::Channel
  def handle_joined
  end

  def handle_message(msg)
    p msg
    event = msg["event"]
    topic = msg["topic"]
    subject = msg["subject"]
    if subject == "post:new"
      message = msg["payload"]["message"]
      author = msg["payload"]["author"]
      rebroadcast!({"event" => event, "topic" => topic, "subject" => subject, "payload" => {"message" => HTML.escape(message.to_s), "author" => HTML.escape(author.to_s)}})
    elsif subject == "board:new"
      board = msg["payload"]["board"]
      rebroadcast!({"event" => event, "topic" => topic, "subject" => subject, "payload" => {"board" => HTML.escape(board.to_s)}})
    end
  end
end