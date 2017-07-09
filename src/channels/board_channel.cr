class BoardChannel < Amber::WebSockets::Channel
  def handle_joined
  end

  def handle_message(msg)
    event = msg["event"]
    topic = msg["topic"]
    subject = msg["subject"]
    message = msg["payload"]["message"]
    author = msg["payload"]["author"]
    rebroadcast!({"event" => event, "topic" => topic, "subject" => subject, "payload" => {"message" => HTML.escape(message.to_s), "author" => HTML.escape(author.to_s)}})
  end
end