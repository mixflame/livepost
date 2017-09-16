class ChatChannel < Amber::WebSockets::Channel
  def handle_joined(client_socket, message)
  end

  def handle_leave(client_socket, message)
  end

  def handle_message(client_socket, message)
    event = message["event"]
    topic = message["topic"]
    subject = message["subject"]
    puts message.inspect
    if subject == "handle:join"
      client = Mongo::Client.new "mongodb://localhost:27017/livepost"
      db = client["live_post"]

      collection = db["online_nicks"]

      nickname = collection.find_one({"$query" => {"name" => {"$eq" => message["payload"]["handle"].to_s}}})

      if nickname.nil? && message["payload"]["handle"].to_s != ""
        collection.insert({"name" => message["payload"]["handle"].to_s})
      end
    elsif subject == "handle:leave"
      client = Mongo::Client.new "mongodb://localhost:27017/livepost"
      db = client["live_post"]

      collection = db["online_nicks"]
      nickname = collection.find_one({"$query" => {"name" => {"$eq" => message["payload"]["handle"].to_s}}})

      if !nickname.nil? && message["payload"]["handle"].to_s != ""
        collection.remove({"name" => message["payload"]["handle"].to_s})
      end
    end

    rebroadcast!(message)
  end
end
