#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'mysql2'
require 'json'

client = Mysql2::Client.new(:host => "localhost", :username => "root", :database => "hootly")

get '/' do
   "hello world"
end

post '/user' do
   user_id = params['user_id']
   client.query("INSERT INTO Users (id) values (#{user_id})")
   "success"
end

get '/hootloot' do
   data = {}
   user_id = params['user_id']
   hootloot = client.query("SELECT hootloot FROM Users where id = #{user_id}")
   data['hootloot'] = hootloot.first['hootloot']
   data.to_json
end

get '/myhoots' do
   user_id = params['user_id']
   comments = client.query("SELECT post_id FROM Comments WHERE user_id = #{user_id}")

   post_ids = []
   comments.each do |comment|
      post_ids.push(comment["post_id"])
   end

   posts = client.query("SELECT id FROM Hoots WHERE user_id = #{user_id}")

   posts.each do |post|
      post_ids.push(posts["id"])
   end
   post_ids = post_ids.to_set
   post_ids.to_json
end

get '/hoot' do
   post_id = params["post_id"]
   post = client.query("SELECT * FROM Hoots where id = #{post_id} and active = true")
   post = post.first
   post_return = {}

   post_return["image_path"] = post["image_path"]
   post_return["hoot_text"] = post["hoot_text"]
   post_return["hootloot"] = post["hootloot"]

   post_return.to_json
end

get '/hoots' do
   lat = params['lat']
   long = params['long']
   #posts = client.query("select * from Hoots limit 50 where active = true")
   posts = client.query("SELECT *, (3659 * acos( cos( radians( #{lat}) ) *
                        cos ( radians( latitude ) ) *
                        cos (radians(longitude) -
                        radians (#{long}) ) +
                        sin ( radians( #{lat} ) ) *
                        sin ( radians( latitude ) ) ) ) as distance
                        FROM Hoots
                        WHERE active = true
                        HAVING distance < 1.5
                        ORDER BY hootloot
                        LIMIT 50")
   posts_return = {}
   posts.each do |post|
      id = post["id"].to_s
      posts_return[id] = {}
      posts_return[id]["image_path"] = post["image_path"]
      posts_return[id]["hoot_text"] = post["hoot_text"]
      posts_return[id]["hootloot"] = post["hootloot"]
   end
   posts_return.to_json
end

# post info
# userid, an image, a caption
post '/hoots' do
   user_id = params["user_id"]
   caption = params['caption']
   timestamp = Time.now.to_i
   lat = params["lat"]
   long = params["long"]

   # determine an image path here
   file_type = ".png"
   imagepath = user_id.to_s + timestamp.to_s + file_type
   img_path_quotes = "\"" + imagepath + "\""

   # This saves the image in the uploads directory
   File.open('./uploads/' + imagepath, "wb") do |f|
        f.write(params['image'][:tempfile].read)
   end

   client.query("INSERT INTO Hoots (user_id, hoot_text, timestamp, image_path, latitude, longitude) VALUES ( #{user_id}, #{caption}, #{timestamp}, #{img_path_quotes}, #{lat}, #{long} )")
end

post '/hootsup' do
   post_id = params['post_id']
   user_id = params['user_id']
   client.query("INSERT INTO Hoots_Upvotes (post_id, user_id) VALUES (#{post_id}, #{user_id})")
   client.query("UPDATE Hoots SET hootloot = hootloot + 1 WHERE id = #{post_id}")
   poster_id = client.query("SELECT * FROM Hoots WHERE id = #{post_id}").first['user_id']
   client.query("UPDATE Users SET hootloot = hootloot + 2 WHERE id = #{poster_id}")
end

post '/hootsdown' do
   post_id = params['post_id']
   user_id = params['user_id']
   client.query("INSERT INTO Hoots_Downvotes (post_id, user_id) VALUES (#{post_id}, #{user_id})")
   client.query("UPDATE Hoots SET hootloot = hootloot - 1 WHERE id = #{post_id}")
   poster_id = client.query("SELECT * FROM Hoots WHERE id = #{post_id}").first['user_id']
   client.query("UPDATE Users SET hootloot = hootloot - 1 WHERE id = #{poster_id}")
end

# example usage
# /comments?postid=1
get '/comments' do
   comments_return = {}
   post_id = params['post_id']
   comments = client.query("select * from Comments where post_id = #{post_id} and active = true")
   requester_user_id = params["user_id"]
   comments.each do |comment|
      vote_dir = 0
      comment_id = comment["id"]
      comment_text = comment["comment_text"]

      score = comment["hootloot"]

      user_upvote = client.query("select sum(vote) as votes from Comments_Upvotes where comment_id = #{comment_id} and user_id = #{requester_user_id}")
      user_downvote = client.query("select sum(vote) as votes from Comments_Downvotes where comment_id = #{comment_id} and user_id = #{requester_user_id}")
      if !user_upvote.first['votes'].nil?
         vote_dir = 1
      end
      if !user_downvote.first['votes'].nil?
         vote_dir = -1
      end
      comments_return[comment_id] = { "comment_id" => comment_id, "comment_text" => comment_text, "score" => score, "requester_vote" => vote_dir }
   end

   comments_return.to_json
end

post '/comments' do
   post_id = params['post_id']
   text = params['text']
   user_id = params['user_id']
   timestamp = Time.now.to_i

   client.query("INSERT INTO Comments (user_id, post_id, comment_text, timestamp) VALUES (#{user_id}, #{post_id}, #{text}, #{timestamp})")
   "success"
end

post '/commentsup' do
   comment_id = params['comment_id']
   user_id = params['user_id']
   client.query("INSERT INTO Comments_Upvotes (comment_id, user_id) VALUES (#{comment_id}, #{user_id})")
   client.query("UPDATE Comments SET hootloot = hootloot + 1 WHERE id = #{comment_id}")
   poster_id = client.query("SELECT * FROM Comments WHERE id = #{comment_id}").first['user_id']
   client.query("UPDATE Users SET hootloot = hootloot + 2 WHERE id = #{poster_id}")
end

post '/commentsdown' do
   comment_id = params['comment_id']
   user_id = params['user_id']
   client.query("INSERT INTO Comments_Downvotes (comment_id, user_id) VALUES (#{comment_id}, #{user_id})")
   client.query("UPDATE Comments SET hootloot = hootloot - 1 WHERE id = #{comment_id}")
   poster_id = client.query("SELECT * FROM Comments WHERE comment_id = #{comment_id}").first['user_id']
   client.query("UPDATE Users SET hootloot = hootloot - 1 WHERE id = #{poster_id}")
end

delete '/hoot' do
   post_id = params['post_id']
   client.query("Update Hoots SET active = false WHERE id = #{post_id}");
end
