require File.expand_path("../../lib/sawyer", __FILE__)
require 'faraday'
require 'pp'

endpoint = "http://localhost:4567/"
faraday  = Faraday.new :url => endpoint

res  = faraday.get '/'
data = Yajl.load(res.body, :symbolize_keys => true)

schemas = {}

# the root endpoint links to the top level relations and their schema
root = Sawyer::Relation.from(data[:_links]).each do |rel|
  # load the schema, set the default href
  res = faraday.get rel.schema_href
  schemas[rel.schema_href] = rel.schema = Sawyer::Schema.read(res.body, res.env[:url])
  rel.href ||= rel.schema.relations['all'].href
end.inject({}) { |map, rel| map.update(rel.name => rel) }

user_rel = root['users']
res      = user_rel.request(faraday)

puts "LISTING USERS"
puts user_rel.inspect
puts user_rel.schema.inspect
puts

Yajl.load(res.body, :symbolize_keys => true).each do |user|
  # load the given rels on this resource
  rels = Sawyer::Relation.from(user[:_links]).inject({}) do |map, rel|
    # merge the rel with the top-level rel that we're accessing
    map.update(rel.name => rel.merge(user_rel.schema, schemas))
  end
  
  puts "#{user[:login]} favorites:"
  res = rels['favorites'].request(faraday)
  Yajl.load(res.body, :symbolize_keys => true).each do |sushi|
    puts "- #{sushi[:name]} (#{sushi[:fish]})"
  end
  puts
end

