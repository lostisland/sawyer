# Sawyer

To use Sawyer, create a new Agent with a URL endpoint.

```ruby
endpoint = "http://my-api.com"
agent    = Sawyer::Agent.new endpoint do |conn|
  conn.headers['content-type'] = 'application/vnd.my-api+json'
end
```

From here, we can access the root to get the initial actions.

```ruby
root = agent.start
```

Every request in Sawyer returns a Sawyer::Response.  It's very similar
to a raw Faraday::Response, with a few extra methods.

```ruby
# HTTP Headers
root.headers

# HTTP status
root.status

# The JSON Schema
root.schema

# The link relations
root.relations

# The contents (probably empty from the root)
root.data
```

Now, we can access a relation off the root.

```ruby
res = root.relations.users do |req|
  req.query['sort'] = 'login'
end

# An array of users
users = res.data
```

This call returns two types of relations: relations on the collection of
users, and relations on each user.  You can access the collection
resources from the response.

```ruby
# get the next page of users
res2 = res.relations.next

# page 2 of the users collection
res2.data
```

Each user has it's own relations too:

```ruby
# favorite the previous user
users.each_with_index do |user, index|
  res = user.relations.favorite users[index-1]
  if !res.success?
    puts "#{user.name} could not favorite #{users[index-1].name}"
  end
end
```

