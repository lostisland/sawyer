# Sawyer

Sawyer is an experimental RESTful user agent built on top of
[Faraday][faraday].

![](http://www.lost-isle.net/images/s5/09x01.jpg)

Think of Faraday as the nerdy scientist behind a REST API.  Sure, he
knows the technical details of how to communicate with an application.
But he also gets overly obsessive about alternate timelines to be of
much use.

![](http://cdn.tvovermind.com/wp-content/uploads/2009/03/lafleur-296x3001.jpg)

Sawyer knows what needs to be done.  He gets in there, assesses the
situation, and figures out the next action.

## What the What?

The main idea is that each resource has a JSON Schema file detailing the
available properties and relations.  The relations describe the schema,
HTTP method, and href.  However, a relation is not accessible on a
resource unless the resource also mentions that relation.  For instance,
a schema of a user may describe these relations:

``` javascript
{ "relations":
  [ {"rel": "self"}
  , {"rel": "update", "method": "patch"}
  , {"rel": "destroy", "method": "delete"}
  , {"rel": "favorites"}
  , {"rel": "favorites:create", "method": "post"}
  ]
}
```

Now, when you get a User, you may see these relations:

``` javascript
{ "_links":
  [ {"rel": "self", "href": "/users/1"}
  , {"rel": "update"}
  , {"rel": "favorites", "href": "/users/1/friends"}
  , {"rel": "favorites:create"}
  ]
}
```

The Sawyer agent should know that the 'destroy' relation is inaccessible
for some reason in the application. 
  
## (Possible) Usage

``` ruby
# SushiHub is a an example REST API -- A social network for Sushi
# Enthusiasts

# setup the auth info and the API endpoint so we can grab the schema 
# info and initial actions.
agent = Sawyer::Agent.new
agent.load 'https://api.sushihub.com'

# salmon is all you need
# mime: application/vnd.sushihub+json
# /nigiri/1
sake = agent.nigiri.get 'sake'

# mime: application/vnd.sushihub+json
# /users/technoweenie
user = agent.user.get 'technoweenie'

# user has "favorites:create" rel with method=POST
user.favorites.create sake
```

## Implemented

This library is experimental.  Don't expect there to be tests, or for
anything to work.  APIs will change.  Sawyer may even be a complete
failure.  Whatever happened, happened.

```ruby
# tested on ruby 1.9.2 with these gems: sinatra, faraday, yajl-ruby
# bundler coming soon, lol
# run example/sushihub.rb to start the example app
#
# start a sawyer console with: `irb -r ./lib/sawyer`
require 'pp'
agent = Sawyer::Agent.new 'http://localhost:4567'

puts agent.inspect

pp agent.schemas.keys
puts agent.schemas['/schema/user'].inspect
pp agent.schemas['/schema/user'].properties

pp agent.relations.keys
pp agent.relations['users']
```

[faraday]: https://github.com/technoweenie/faraday

