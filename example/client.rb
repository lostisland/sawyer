require File.expand_path("../../lib/sawyer", __FILE__)
require 'faraday'
require 'pp'

endpoint = "http://localhost:4567/"
agent    = Sawyer::Agent.new(endpoint) do |http|
  http.headers['content-type'] = 'application/json'
end
puts agent.inspect
puts

puts "ROOT RELATIONS"
pp agent.relations
puts

puts "LISTING USERS"
users_rel = agent.relation('users')

puts users_rel.inspect
puts users_rel.schema.inspect
puts

agent.request(users_rel).each do |user|
  fav_rel = user.relations['favorites']

  puts "#{user[:login]} favorites:"
  puts fav_rel.schema.inspect

  fav_rel.request.each do |sushi|
    puts "- #{sushi.inspect})"
  end
  puts
end

puts "CREATING USER"
create_user_rel = agent.relation("users/create")

puts create_user_rel.inspect

created = create_user_rel.request(:login => 'booya')
puts created.inspect
puts

puts "ADD A FAVORITE"


