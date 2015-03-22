#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require './helpers'
require 'mysql2'
require 'json'
require 'apns'
require 'dimensions'
require 'fastimage_resize'

class Hootly_API < Sinatra::Base

   helpers do
      include Sinatra::ParameterCheck
      include Sinatra::ParameterEscape
      include Sinatra::PushNotifications
   end

	client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => ENV["HOOTLY_DB_PASSWORD"], :database => "hootly", :reconnect => true)
        APNS.pem = 'push_certs/ck.pem'
        APNS.pass = 'LorraineCucumber42'

	get '/' do
	   "hello world"
	end

	post '/newuser' do
	   timestamp = Time.now.to_i
	   suffix = (0...32).map { (65 + rand(26)).chr }.join
	   user_id = timestamp.to_s + suffix

	   client.query("INSERT INTO Users (id) values ('#{user_id}')")
	   return {"user_id" => user_id}.to_json
	end

   post '/newtoken' do
      parameters = ['token', 'user_id']
      error = check_params(parameters)
      if !error.empty?
         return error
      end
      escape_parameters = ['token', 'user_id']
      escape_params(escape_parameters, client)

      token = params['token']
      user_id = params['user_id']

      client.query("UPDATE Users SET device_token = '#{token}' WHERE id = '#{user_id}'")
   end

	get '/hootloot' do

      parameters = ['user_id']
      error = check_params(parameters)
      if !error.empty?
         return error
      end

      escape_parameters = ['user_id']
      escape_params(escape_parameters, client)

	   data = {}
	   user_id = params['user_id']
	   hootloot = client.query("SELECT hootloot FROM Users where id = '#{user_id}'")
	   if hootloot.first
	      data['hootloot'] = hootloot.first['hootloot']
	   end
	   data.to_json
	end

	get '/myhoots' do
      parameters = ['user_id']
      error = check_params(parameters)
      if !error.empty?
         return error
      end

	   user_id = params['user_id']
	   user_id = client.escape(user_id)
	   comments = client.query("SELECT post_id FROM Comments WHERE user_id = '#{user_id}'")

	   post_ids = []
	   comments.each do |comment|
	      post_ids.push(comment["post_id"])
	   end

	   posts = client.query("SELECT id FROM Hoots WHERE user_id = '#{user_id}'")

	   posts.each do |post|
	      post_ids.push(post["id"])
	   end
	   post_ids = post_ids.to_set

	   posts_return = []
	   post_ids.each do |post_id|
	      post = client.query("SELECT * FROM Hoots WHERE id =#{post_id}").first
	      id = post["id"]
	      cur_post = {}
	      cur_post["id"] = post["id"]
	      cur_post["image_path"] = 'uploads/' + post["image_path"]
	      cur_post["hoot_text"] = post["hoot_text"]
	      cur_post["hootloot"] = post["hootloot"]
	      cur_post["timestamp"] = post["timestamp"]
         cur_post["mine"] = post["user_id"] == user_id
	      vote_dir = 0
	      user_upvote = client.query("select sum(vote) as votes from Hoots_Upvotes where hoot_id = #{id} and user_id = '#{user_id}'")
	      user_downvote = client.query("select sum(vote) as votes from Hoots_Downvotes where hoot_id = #{id} and user_id = '#{user_id}'")
	      if !user_upvote.first['votes'].nil?
		      vote_dir = 1
	      end
	      if !user_downvote.first['votes'].nil?
		      vote_dir = -1
	      end

	      cur_post["requester_vote"] = vote_dir

	      num_comments = 0
	      num_comments = client.query("SELECT count(*) as num_comments FROM Comments WHERE post_id = #{id} and active = true").first["num_comments"]
	      cur_post["num_comments"] = num_comments
	      posts_return.push(cur_post)
	   end
	   posts_return.to_json
	end

	get '/hoot' do
      parameters = ['user_id', 'post_id']
      error = check_params(parameters)
      if !error.empty?
         return error
      end

      escape_parameters = ['user_id', 'post_id']
      escape_params(escape_parameters, client)

	   post_id = params["post_id"]
	   user_id = params["user_id"]

	   post = client.query("SELECT * FROM Hoots where id = #{post_id} and active = true")
	   post = post.first
	   post_return = {}

	   post_return["image_path"] = 'uploads/' + post["image_path"]
	   post_return["hoot_text"] = post["hoot_text"]
	   post_return["hootloot"] = post["hootloot"]
      post_return["timestamp"] = post["timestamp"]
      post_return["mine"] = post["user_id"] == user_id

	   vote_dir = 0
	   user_upvote = client.query("select sum(vote) as votes from Hoots_Upvotes where hoot_id = #{post_id} and user_id = '#{user_id}'")
	   user_downvote = client.query("select sum(vote) as votes from Hoots_Downvotes where hoot_id = #{post_id} and user_id = '#{user_id}'")
	   if !user_upvote.first['votes'].nil?
	      vote_dir = 1
	   end
	   if !user_downvote.first['votes'].nil?
	      vote_dir = -1
	   end

	   post_return["requester_vote"] = vote_dir

	   post_return.to_json
	end

	get '/hoots' do
      parameters = ['lat', 'long', 'user_id']
      error = check_params(parameters)
      if !error.empty?
         return error
      end

      escape_parameters = ['lat', 'long', 'user_id']
      escape_params(escape_parameters, client)

	   lat = params['lat']
	   long = params['long']
	   user_id = params['user_id']

      posts = client.query("SELECT *, (7926 *
                                       asin( sqrt( pow(sin((radians(latitude) - radians(#{lat}))/2), 2) +
                                                   cos(radians(#{lat})) * cos(radians(latitude)) *
                                                   pow(sin((radians(longitude) - radians(#{long}))/2), 2)))) as distance
                            FROM Hoots
                            WHERE active = true
                            HAVING distance < 1.5
                            ORDER BY timestamp DESC
                            LIMIT 50")

	   posts_return = []
	   posts.each do |post|
	      id = post["id"].to_s
	      cur_post = {}
	      cur_post["id"] = post["id"]
	      cur_post["image_path"] = 'uploads/' + post["image_path"]
	      cur_post["hoot_text"] = post["hoot_text"]
	      cur_post["hootloot"] = post["hootloot"]
	      cur_post["timestamp"] = post["timestamp"]
         cur_post["mine"] = post["user_id"] == user_id
	      vote_dir = 0
	      user_upvote = client.query("select sum(vote) as votes from Hoots_Upvotes where hoot_id = #{id} and user_id = '#{user_id}'")
	      user_downvote = client.query("select sum(vote) as votes from Hoots_Downvotes where hoot_id = #{id} and user_id = '#{user_id}'")

	      if !user_upvote.first['votes'].nil?
            vote_dir = 1
	      end
	      if !user_downvote.first['votes'].nil?
            vote_dir = -1
	      end

	      cur_post["requester_vote"] = vote_dir
	      num_comments = 0
	      num_comments = client.query("SELECT count(*) as num_comments FROM Comments WHERE post_id = #{id} and active = true").first["num_comments"]
	      cur_post["num_comments"] = num_comments

	      posts_return.push(cur_post)
	   end
	   posts_return.to_json
	end

	# post info
	# userid, an image, a hoot_text
	post '/hoots' do
      parameters = ['user_id', 'hoot_text', 'lat', 'long']
      error = check_params(parameters)
      if !error.empty?
         return ["error" => error].to_json
      end


	   user_id = params["user_id"]
	   hoot_text = params['hoot_text']
	   timestamp = Time.now.to_i
	   lat = params["lat"]
	   long = params["long"]

      hoot_character_limit = 140
      if hoot_text.size > hoot_character_limit
         return ["error" => "hoot character count exceeded limit"].to_json
      end

      device_token = '987cb0a6d68138d3e06188c99c1ea60c5cbed40650d7cc4d8d8cfee2dd338d2b'
      APNS.send_notification(device_token, :alert => 'A hoot has been posted', :badge => 1, :sound => 'default')

	   user_id = client.escape(user_id)
	   hoot_text = client.escape(hoot_text)

	   lat = client.escape(lat)
	   long = client.escape(long)

	   # determine an image path here
	   file_type = ".jpeg"
	   imagepath = user_id.to_s + timestamp.to_s + file_type

	   # This saves the image in the uploads directory
      img_dimensions =  Dimensions.dimensions(params['image'][:tempfile])
      square_image = params['image'][:tempfile]

      side_length = img_dimensions[0]
      if img_dimensions[0] > img_dimensions[1]
         side_length = img_dimensions[1]
      else
         side_length = img_dimensions[0]
      end
      if img_dimensions[0] != img_dimensions[1]
         square_image = FastImage.resize(square_image, side_length, side_length)
      end

      if side_length > 640
         square_image = FastImage.resize(square_image, 640, 640)
      end

	   File.open('./uploads/' + imagepath, "wb") do |f|
		   #f.write(params['image'][:tempfile].read)
         f.write(square_image.read)
	   end

	   client.query("INSERT INTO Hoots (user_id, hoot_text, timestamp, image_path, latitude, longitude) VALUES ( '#{user_id}', '#{hoot_text}', #{timestamp}, '#{imagepath}', #{lat}, #{long} )")
           ["success"].to_json
	end

	post '/hootsup' do
      parameters = ['post_id', 'user_id']
      error = check_params(parameters)
      if !error.empty?
         return error
      end

	   post_id = params['post_id']
	   user_id = params['user_id']
	   post_id = client.escape(post_id)
	   user_id = client.escape(user_id)

	   client.query("INSERT INTO Hoots_Upvotes (hoot_id, user_id) VALUES (#{post_id}, '#{user_id}')")
	   client.query("UPDATE Hoots SET hootloot = hootloot + 1 WHERE id = #{post_id}")
	   client.query("UPDATE Hoots SET votes = votes + 1 WHERE id = #{post_id}")
	   poster_id = client.query("SELECT * FROM Hoots WHERE id = #{post_id}").first['user_id']
	   client.query("UPDATE Users SET hootloot = hootloot + 2 WHERE id = '#{poster_id}'")

      hoot_vote_activity(post_id, client)
	end

	post '/hootsdown' do
      parameters = ['post_id', 'user_id']
      error = check_params(parameters)
      if !error.empty?
         return error
      end

      escape_parameters = ['post_id', 'user_id']
      escape_params(escape_parameters, client)

	   post_id = params['post_id']
	   user_id = params['user_id']
	   post_id = client.escape(post_id)
	   user_id = client.escape(user_id)

	   client.query("INSERT INTO Hoots_Downvotes (hoot_id, user_id) VALUES (#{post_id}, '#{user_id}')")
	   client.query("UPDATE Hoots SET hootloot = hootloot - 1 WHERE id = #{post_id}")
	   client.query("UPDATE Hoots SET votes = votes + 1 WHERE id = #{post_id}")
	   poster_id = client.query("SELECT * FROM Hoots WHERE id = #{post_id}").first['user_id']
	   client.query("UPDATE Users SET hootloot = hootloot - 1 WHERE id = '#{poster_id}'")

	   hoot_hootloot = client.query("SELECT hootloot FROM Hoots WHERE id = #{post_id}").first['hootloot']
	   if hoot_hootloot <= -5
	      client.query("UPDATE Hoots SET active = false WHERE id = #{post_id}")
	   end

      hoot_vote_activity(post_id, client)
	end

	# example usage
	# /comments?postid=1&user_id=1
	get '/comments' do
      parameters = ['post_id', 'user_id']
      error = check_params(parameters)
      if !error.empty?
         return error
      end

	   comments_return = []
	   post_id = params['post_id']
	   post_id = client.escape(post_id)

	   comments = client.query("select * from Comments where post_id = #{post_id} and active = true")
	   requester_user_id = params["user_id"]
	   requester_user_id = client.escape(requester_user_id)
	   comments.each do |comment|
	      vote_dir = 0
	      comment_id = comment["id"]
	      comment_text = comment["comment_text"]
              comment_timestamp = comment["timestamp"]

	      score = comment["hootloot"]

	      user_upvote = client.query("select sum(vote) as votes from Comments_Upvotes where comment_id = #{comment_id} and user_id = '#{requester_user_id}'")
	      user_downvote = client.query("select sum(vote) as votes from Comments_Downvotes where comment_id = #{comment_id} and user_id = '#{requester_user_id}'")
	      if !user_upvote.first['votes'].nil?
		 vote_dir = 1
	      end
	      if !user_downvote.first['votes'].nil?
		 vote_dir = -1
	      end
	      comments_return.push({ "comment_id" => comment_id, "comment_text" => comment_text, "score" => score, "requester_vote" => vote_dir, "timestamp" => comment_timestamp })
	   end

	   comments_return.to_json
	end

	post '/comments' do
      parameters = ['post_id', 'text', 'user_id']
      error = check_params(parameters)
      if !error.empty?
         return error
      end

	   post_id = params['post_id']
	   text = params['text']
	   user_id = params['user_id']

	   post_id = client.escape(post_id)
	   text = client.escape(text)
	   user_id = client.escape(user_id)

	   timestamp = Time.now.to_i

	   client.query("INSERT INTO Comments (user_id, post_id, comment_text, timestamp) VALUES ('#{user_id}', #{post_id}, '#{text}', #{timestamp})")

      reply_activity(post_id, client)
      ["success"].to_json
	end

	post '/commentsup' do
      parameters = ['comment_id', 'user_id']
      error = check_params(parameters)
      if !error.empty?
         return error
      end

      escape_parameters = ['comment_id', 'user_id']
      escape_params(escape_parameters, client)

	   comment_id = params['comment_id']
	   user_id = params['user_id']

	   client.query("INSERT INTO Comments_Upvotes (comment_id, user_id) VALUES (#{comment_id}, '#{user_id}')")
	   client.query("UPDATE Comments SET hootloot = hootloot + 1 WHERE id = #{comment_id}")
	   client.query("UPDATE Comments SET votes = votes + 1 WHERE id = #{comment_id}")

	   poster_id = client.query("SELECT * FROM Comments WHERE id = #{comment_id}").first['user_id']
	   client.query("UPDATE Users SET hootloot = hootloot + 2 WHERE id = '#{poster_id}'")

      comment_vote_activity(comment_id, client)
	end

	post '/commentsdown' do
      parameters = ['comment_id', 'user_id']
      error = check_params(parameters)
      if !error.empty?
         return error
      end

      escape_parameters = ['comment_id', 'user_id']
      escape_params(escape_parameters, client)

	   comment_id = params['comment_id']
	   user_id = params['user_id']

	   client.query("INSERT INTO Comments_Downvotes (comment_id, user_id) VALUES (#{comment_id}, '#{user_id}')")
	   client.query("UPDATE Comments SET hootloot = hootloot - 1 WHERE id = #{comment_id}")
	   client.query("UPDATE Comments SET votes = votes + 1 WHERE id = #{comment_id}")
	   poster_id = client.query("SELECT * FROM Comments WHERE id = #{comment_id}").first['user_id']
	   client.query("UPDATE Users SET hootloot = hootloot - 1 WHERE id = '#{poster_id}'")

	   comment_hootloot = client.query("SELECT hootloot FROM Comments WHERE id = #{comment_id}").first['hootloot']
	   if comment_hootloot <= -5
	      client.query("UPDATE Comments SET active = false WHERE id = #{comment_id}")
	   end

      comment_vote_activity(comment_id, client)
	end

	delete '/hoot' do
      parameters = ['post_id']
      error = check_params(parameters)
      if !error.empty?
         return error
      end

      escape_parameters = ['post_id']
      escape_params(escape_parameters, client)

	   post_id = params['post_id']

	   client.query("Update Hoots SET active = false WHERE id = #{post_id}");
	end
end
