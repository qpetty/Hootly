require 'json'

result = `curl --data '' localhost:4567/newuser`
user_id = JSON.parse(result)["user_id"]

result = `curl localhost:4567/hootloot?user_id=#{user_id}`
hootloot = JSON.parse(result)["hootloot"]


`curl --form "image=@/Users/brandon/Desktop/img.png" --form user_id=#{user_id} --form lat=5 --form long=5 --form hoot_text="hello" localhost:4567/hoots`

result = `curl "localhost:4567/hoots?lat=5&long=5&user_id=#{user_id}"`
hoots = JSON.parse(result)

hoots.each do |hoot|
   `curl --form text="this is a comment" --form post_id=#{hoot[0]} --form user_id=#{user_id} localhost:4567/comments`
end

`curl --form comment_id=1 --form user_id=#{user_id} localhost:4567/commentsup`
`curl --form post_id=1 --form user_id=#{user_id} localhost:4567/hootsup`

`curl --form comment_id=1 --form user_id=#{user_id} localhost:4567/commentsdown`
`curl --form post_id=1 --form user_id=#{user_id} localhost:4567/hootsdown`

result = `curl "localhost:4567/comments?post_id=1&user_id=#{user_id}"`

comments = JSON.parse(result)

comments.each do |c|
   p c
end

