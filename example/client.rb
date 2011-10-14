require File.expand_path("../../lib/sawyer", __FILE__)
require 'faraday'
require 'pp'

endpoint = "http://localhost:4567/"
faraday  = Faraday.new \
  :url => endpoint,
  :headers => {'content-type' => 'application/json'}

res  = faraday.get '/'
data = Yajl.load(res.body, :symbolize_keys => true)

schemas = {}
root    = {}

# the root endpoint links to the top level relations and their schema
Sawyer::Relation.from(data[:_links]).each do |rel|
  # load the schema, set the default href
  res = faraday.get rel.schema_href
  schemas[rel.schema_href] ||= begin
    schema   = Sawyer::Schema.read(res.body, res.env[:url])
    root_rel = root[rel.name] = schema.relations['all']

    schema.relations.each do |key, schema_rel|
      schema_rel.schema = schema
      next if key == 'all' || schema_rel.href != root_rel.href
      root["#{rel.name}/#{key}"] = schema_rel
    end

    root_rel.schema = schema
  end
end

puts "ROOT RELATIONS"
pp root
puts

puts "LISTING USERS"
user_rel = root['users']

puts user_rel.inspect
puts user_rel.schema.inspect
puts

res = user_rel.request(faraday)

Yajl.load(res.body, :symbolize_keys => true).each do |user|
  # load the given rels on this resource
  rels = Sawyer::Relation.from(user[:_links]).inject({}) do |map, rel|
    # merge the rel with the top-level rel that we're accessing
    map.update(rel.name => rel.merge(user_rel.schema, schemas))
  end
  
  fav_rel = rels['favorites']
  res = fav_rel.request(faraday)

  puts "#{user[:login]} favorites:"
  puts fav_rel.schema.inspect
  Yajl.load(res.body, :symbolize_keys => true).each do |sushi|
    puts "- #{sushi[:name]} (#{sushi[:fish]})"
  end
  puts
end

puts "CREATING USER"
create_user_rel = root["users/create"]

puts create_user_rel.inspect

res = create_user_rel.request(faraday, Yajl.dump(:login => 'booya'))
puts "#{res.status} #{res.headers['location']}"
puts res.body

