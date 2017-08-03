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

  def check_captcha
    if !params.has_key?("captcha_response")
      raise "botting"
      # response.close
      puts "no recaptcha response... connection closed."
      return
    end
    p "hash response: #{OpenSSL::Digest.new("SHA256").update(params["captcha_response"])}"
    p "captcha_key: #{session["captcha_key"]}"
    bot = OpenSSL::Digest.new("SHA256").update(params["captcha_response"].downcase).to_s != session["captcha_key"].to_s
    if bot
      raise "botting"
      # response.close
      puts "attempted botting... connection closed."
    end
  end
end