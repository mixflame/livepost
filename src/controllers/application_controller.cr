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
    !collection("banned_hashes").find_one({"ip_hash" => OpenSSL::Digest.new("SHA256").update(request.host.to_s).to_s}).nil?
  end

  def check_ban
    if banned?
      response.close
      puts "BANNED ip hash just tried connecting. connection closed."
    end
  end

  def check_recaptcha
    if !params.has_key?("g-recaptcha-response")
      response.close
      puts "no recaptcha response... connection closed."
      return
    end
    recaptcha_info = JSON.parse(HTTP::Client.post("https://www.google.com/recaptcha/api/siteverify?secret=6LfXZysUAAAAAK0vVqxKP9dBYvAnSsrtpcmFSicr&response=#{params["g-recaptcha-response"]}").body)
    puts recaptcha_info
    bot = recaptcha_info["success"] == false
    if bot
      response.close
      puts "attempted botting... connection closed."
    end
  end
end