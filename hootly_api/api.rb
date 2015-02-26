#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'mysql2'
require 'json'

class Hootly_API < Sinatra::Base
	client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => ENV["HOOTLY_DB_PASSWORD"], :database => "hootly")

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

	get '/hootloot' do
	   data = {}
	   user_id = params['user_id']
	   user_id = client.escape(user_id)
	   hootloot = client.query("SELECT hootloot FROM Users where id = '#{user_id}'")
	   if hootloot.first
	      data['hootloot'] = hootloot.first['hootloot']
	   end
	   data.to_json
	end

	get '/myhoots' do
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
	      cur_post["image_path"] = post["image_path"]
	      cur_post["hoot_text"] = post["hoot_text"]
	      cur_post["hootloot"] = post["hootloot"]
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
	      posts_return.push(cur_post)
	   end
	   posts_return.to_json
	end

	get '/hoot' do
	   post_id = params["post_id"]
	   post_id = client.escape(post_id)
	   user_id = params["user_id"]
	   user_id = client.escape(user_id)

	   post = client.query("SELECT * FROM Hoots where id = #{post_id} and active = true")
	   post = post.first
	   post_return = {}

	   post_return["image_path"] = 'uploads/' + post["image_path"]
	   post_return["hoot_text"] = post["hoot_text"]
	   post_return["hootloot"] = post["hootloot"]

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
	   lat = params['lat']
	   long = params['long']
	   user_id = params['user_id']
	   lat = client.escape(lat)
	   long = client.escape(long)
	   user_id = client.escape(user_id)

	   #posts = client.query("SELECT *, (3659 * acos( cos( radians( #{lat}) ) *
		#		cos ( radians( latitude ) ) *
		#		cos (radians(longitude) -
		#		radians (#{long}) ) +
		#		sin ( radians( #{lat} ) ) *
		#		sin ( radians( latitude ) ) ) ) as distance
		#		FROM Hoots
		#		WHERE active = true
		#		HAVING distance < 1.5
		#		ORDER BY hootloot
		#		LIMIT 50")
      #
      posts = client.query("SELECT *, (7926 *
                                       asin( sqrt( pow(sin((latitude - #{lat})/2), 2) +
                                                   cos(#{lat}) * cos(latitude) *
                                                   pow(sin((longitude - #{long})/2), 2)))) as distance
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
      error = ""
	   user_id = params["user_id"]
	   hoot_text = params['hoot_text']
	   timestamp = Time.now.to_i
	   lat = params["lat"]
	   long = params["long"]

      if user_id.nil?
         error = error + "User id is nil. "
      end
      if hoot_text.nil?
         error = error + "Hoot text is nil. "
      end
      if timestamp.nil?
         error = error + "Timestamp is nil. "
      end
      if lat.nil?
         error = error + "Latitude is nil. "
      end
      if long.nil?
         error = error + "Longitude is nil. "
      end

      if !error.empty?
         return error
      end

	   user_id = client.escape(user_id)
	   hoot_text = client.escape(hoot_text)

	   lat = client.escape(lat)
	   long = client.escape(long)

	   # determine an image path here
	   file_type = ".png"
	   imagepath = user_id.to_s + timestamp.to_s + file_type

	   # This saves the image in the uploads directory
	   File.open('./uploads/' + imagepath, "wb") do |f|
		f.write(params['image'][:tempfile].read)
	   end

	   client.query("INSERT INTO Hoots (user_id, hoot_text, timestamp, image_path, latitude, longitude) VALUES ( '#{user_id}', '#{hoot_text}', #{timestamp}, '#{imagepath}', #{lat}, #{long} )")
	end

	post '/hootsup' do
	   post_id = params['post_id']
	   user_id = params['user_id']
	   post_id = client.escape(post_id)
	   user_id = client.escape(user_id)

	   client.query("INSERT INTO Hoots_Upvotes (hoot_id, user_id) VALUES (#{post_id}, '#{user_id}')")
	   client.query("UPDATE Hoots SET hootloot = hootloot + 1 WHERE id = #{post_id}")
	   poster_id = client.query("SELECT * FROM Hoots WHERE id = #{post_id}").first['user_id']
	   client.query("UPDATE Users SET hootloot = hootloot + 2 WHERE id = '#{poster_id}'")
	end

	post '/hootsdown' do
	   post_id = params['post_id']
	   user_id = params['user_id']
	   post_id = client.escape(post_id)
	   user_id = client.escape(user_id)

	   client.query("INSERT INTO Hoots_Downvotes (hoot_id, user_id) VALUES (#{post_id}, '#{user_id}')")
	   client.query("UPDATE Hoots SET hootloot = hootloot - 1 WHERE id = #{post_id}")
	   poster_id = client.query("SELECT * FROM Hoots WHERE id = #{post_id}").first['user_id']
	   client.query("UPDATE Users SET hootloot = hootloot - 1 WHERE id = '#{poster_id}'")

	   hoot_hootloot = client.query("SELECT hootloot FROM Hoots WHERE id = #{post_id}").first['hootloot']
	   if hoot_hootloot <= -5
	      client.query("UPDATE Comments SET active = false WHERE id = #{post_id}")
	   end
	end

	# example usage
	# /comments?postid=1&user_id=1
	get '/comments' do
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
	   post_id = params['post_id']
	   text = params['text']
	   user_id = params['user_id']

	   post_id = client.escape(post_id)
	   text = client.escape(text)
	   user_id = client.escape(user_id)

	   timestamp = Time.now.to_i

	   client.query("INSERT INTO Comments (user_id, post_id, comment_text, timestamp) VALUES ('#{user_id}', #{post_id}, '#{text}', #{timestamp})")
	   "success"
	end

	post '/commentsup' do
	   comment_id = params['comment_id']
	   user_id = params['user_id']
	   comment_id = client.escape(comment_id)
	   user_id = client.escape(user_id)

	   client.query("INSERT INTO Comments_Upvotes (comment_id, user_id) VALUES (#{comment_id}, '#{user_id}')")
	   client.query("UPDATE Comments SET hootloot = hootloot + 1 WHERE id = #{comment_id}")

	   poster_id = client.query("SELECT * FROM Comments WHERE id = #{comment_id}").first['user_id']
	   client.query("UPDATE Users SET hootloot = hootloot + 2 WHERE id = '#{poster_id}'")
	end

	post '/commentsdown' do
	   comment_id = params['comment_id']
	   user_id = params['user_id']
	   comment_id = client.escape(comment_id)
	   user_id = client.escape(user_id)

	   client.query("INSERT INTO Comments_Downvotes (comment_id, user_id) VALUES (#{comment_id}, '#{user_id}')")
	   client.query("UPDATE Comments SET hootloot = hootloot - 1 WHERE id = #{comment_id}")
	   poster_id = client.query("SELECT * FROM Comments WHERE id = #{comment_id}").first['user_id']
	   client.query("UPDATE Users SET hootloot = hootloot - 1 WHERE id = '#{poster_id}'")

	   comment_hootloot = client.query("SELECT hootloot FROM Comments WHERE id = #{comment_id}").first['hootloot']
	   if comment_hootloot <= -5
	      client.query("UPDATE Comments SET active = false WHERE id = #{comment_id}")
	   end
	end

	delete '/hoot' do
	   post_id = params['post_id']
	   post_id = client.escape(post_id)

	   client.query("Update Hoots SET active = false WHERE id = #{post_id}");
	end
end
