class ApplicationController < Amber::Controller::Base
  LAYOUT = "application.ecr"
  @client = Mongo::Client.new "mongodb://localhost:27017/livepost"

  before_action do
    all { check_ban }
  end

  def collection(collection_name)
    @client["live_post"][collection_name]
  end

  def banned?
    ip = request.headers["X-Forwarded-For"].to_s rescue ""
    ip_hash = OpenSSL::Digest.new("SHA256").update(ip).to_s
    !collection("banned_hashes").find_one({"ip_hash" => ip_hash}).nil?
  end

  def check_ban
    if banned?
      response.close
      puts "BANNED ip hash just tried connecting. connection closed."
    end
  end
end
