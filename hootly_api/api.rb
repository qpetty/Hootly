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

# example usage
# /clamors?lat=1.4&long=4.3
get '/hoots' do
   lat = params['lat']
   long = params['long']
   posts = client.query("select * from posts limit 50")
   posts.each do |post|
      p post["id"]
   end
   #posts.first.to_json unless posts.nil?
   posts
end

# post info
# userid, an image, a caption
post '/hoots' do
   user_id = params['user_id']
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

   client.query("INSERT INTO Hoots (user_id, caption, timestamp, image_path, latitude, longitude)
                VALUES ( #{user_id}, #{caption}, #{timestamp}, #{img_path_quotes}, #{lat}, #{long} )")
   "success\n"
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
   comments = client.query("select * from Comments where post_id = #{post_id}")
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

   client.query("INSERT INTO Comments (user_id, post_id, comment_text) VALUES (#{user_id}, #{post_id}, #{text})")
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
