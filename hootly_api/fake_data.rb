require 'json'

host = ARGV[0]
host = 'http://www.anappnooneneeds.com' if host.nil?

result = `curl --data '' #{host}/newuser`
user_id = JSON.parse(result)["user_id"]

result = `curl #{host}/hootloot?user_id=#{user_id}`
hootloot = JSON.parse(result)["hootloot"]


`curl --form "image=@/Users/brandon/Desktop/img.png" --form user_id=#{user_id} --form lat=5 --form long=5 --form hoot_text="hello" #{host}/hoots`

result = `curl "#{host}/hoots?lat=5&long=5&user_id=#{user_id}"`
hoots = JSON.parse(result)
p hoots

hoots.each do |hoot|
   `curl --form text="this is a comment" --form post_id=#{hoot["id"]} --form user_id=#{user_id} #{host}/comments`
end

`curl --form comment_id=1 --form user_id=#{user_id} #{host}/commentsup`
`curl --form post_id=1 --form user_id=#{user_id} #{host}/hootsup`

`curl --form comment_id=1 --form user_id=#{user_id} #{host}/commentsdown`
`curl --form post_id=1 --form user_id=#{user_id} #{host}/hootsdown`

result = `curl "#{host}/comments?post_id=1&user_id=#{user_id}"`

comments = JSON.parse(result)

comments.each do |c|
   p c
end

