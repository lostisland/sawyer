require File.expand_path("../../lib/sawyer", __FILE__)
require 'faraday'
require 'pp'

endpoint = "http://localhost:9393/"
agent    = Sawyer::Agent.new(endpoint) do |http|
  http.headers['content-type'] = 'application/json'
end
puts agent.inspect
puts

root = agent.start
puts root.inspect

puts "LISTING USERS"
users_rel = root.data.rels[:users]

puts users_rel.inspect
puts

users_res = users_rel.get
puts users_res.inspect

users = users_res.data

users.each do |user|
  puts "#{user.login} favorites:"

  fav_res = user.rels[:favorites].get

  fav_res.data.each do |sushi|
    puts "- #{sushi.inspect})"
  end
  puts
end

puts "CREATING USER"
create_user_rel = root.data.rels[:users]

puts create_user_rel.inspect

created = create_user_rel.post(:login => 'booya')
puts created.inspect
puts

puts "ADD A FAVORITE"
created_user = created.data
create_fav_res = created_user.rels[:favorites].post nil, :query => {:id => 1}
puts create_fav_res.inspect

