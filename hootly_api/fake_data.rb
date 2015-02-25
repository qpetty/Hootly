require 'json'

result = `curl --data '' http://www.anappnooneneeds.com/newuser`
user_id = JSON.parse(result)["user_id"]

result = `curl http://www.anappnooneneeds.com/hootloot?user_id=#{user_id}`
hootloot = JSON.parse(result)["hootloot"]


`curl --form "image=@/Users/brandon/Desktop/img.png" --form user_id=#{user_id} --form lat=5 --form long=5 --form hoot_text="hello" http://www.anappnooneneeds.com/hoots`

result = `curl "http://www.anappnooneneeds.com/hoots?lat=5&long=5&user_id=#{user_id}"`
hoots = JSON.parse(result)
p hoots

hoots.each do |hoot|
   `curl --form text="this is a comment" --form post_id=#{hoot["id"]} --form user_id=#{user_id} http://www.anappnooneneeds.com/comments`
end

`curl --form comment_id=1 --form user_id=#{user_id} http://www.anappnooneneeds.com/commentsup`
`curl --form post_id=1 --form user_id=#{user_id} http://www.anappnooneneeds.com/hootsup`

`curl --form comment_id=1 --form user_id=#{user_id} http://www.anappnooneneeds.com/commentsdown`
`curl --form post_id=1 --form user_id=#{user_id} http://www.anappnooneneeds.com/hootsdown`

result = `curl "http://www.anappnooneneeds.com/comments?post_id=1&user_id=#{user_id}"`

comments = JSON.parse(result)

comments.each do |c|
   p c
end

