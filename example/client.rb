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
user_rel = agent.relation('users')

puts user_rel.inspect
puts user_rel.schema.inspect
puts

agent.request(user_rel).each do |user|
  fav_rel = user.relations['favorites']

  puts "#{user[:login]} favorites:"
  puts fav_rel.schema.inspect
  agent.request(fav_rel).each do |sushi|
    puts "- #{sushi.inspect})"
  end
  puts
end

puts "CREATING USER"
create_user_rel = agent.relation("users/create")

puts create_user_rel.inspect

created = agent.request(create_user_rel, :login => 'booya')
puts created.inspect
puts

puts "ADD A FAVORITE"


