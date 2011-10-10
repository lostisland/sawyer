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
  
## (Possible) Usage

``` ruby
# SushiHub is a an example REST API -- A social network for Sushi
# Enthusiasts

# setup the auth info and the API endpoint so we can grab the schema 
# info and initial actions.
agent = Sawyer::Agent.new
agent.load 'https://api.sushihub.com'

# salmon is all you need
# mime: application/vnd.sushihub.nigiri+json
# /nigiri/1
sake = agent.nigiri.get 'sake'

# mime: application/vnd.sushihub.user+json
# /users/technoweenie
user = agent.user.get 'technoweenie'

# user has "favorites:create" rel with method=POST
user.favorites.create sake
```

## Implemented

This library is experimental.  Don't expect there to be tests, or for
anything to work.  APIs will change.  Sawyer may even be a complete
failure.

```ruby
# tested on ruby 1.9.2 with these gems: sinatra, faraday, yajl-ruby
# bundler coming soon, lol
# run example/sushihub.rb to start the example app
#
# start a sawyer console with: `irb -r ./lib/sawyer`
require 'pp'
agent = Sawyer::Agent.new
agent.load 'http://localhost:4567'

pp agent.profiles.keys
pp agent.profiles['/schema/user'].properties
```

[faraday]: https://github.com/technoweenie/faraday

