class StaticController < ApplicationController
  def index
    "404 not found"
  end
  def slug
    # board page
    puts context.session.to_h
    client = Mongo::Client.new "mongodb://localhost:27017/livepost"
    db = client["live_post"]

    boards = db["boards"]

    collection = db["messages"]
    @board_name = URI.unescape(params["slug"])

    if boards.find_one({"name" => @board_name}).nil?
      return "invalid board"
    end

    last_posted = collection.find_one({"$query" => {"timestamp" => {"$ne" => ""}}, "$orderby": {"timestamp" => -1}})

    last_posted_author = last_posted.nil? ? "" : last_posted["author"]

    last_posted = last_posted.nil? ? "" : last_posted["name"]

    session["test"] = "test"
    render("board.ecr")
  end

  def captcha_image
    images = Dir.glob("#{File.dirname(APP_PATH)}/../public/captcha_images/*")
    image = File.basename(images[rand(images.size)])
    name = image.split(".png").first
    cookies["captcha_key"] = OpenSSL::Digest.new("SHA256").update(name.to_s).to_s
    puts cookies["captcha_key"].to_s
    File.read("#{File.dirname(APP_PATH)}/../public/captcha_images/#{image}")
  end
end