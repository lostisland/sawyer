# Sawyer

Sawyer is an experimental secret user agent built on top of
[Faraday][faraday].

![](http://www.lost-isle.net/images/s5/09x01.jpg)

Think of Faraday as the nerdy scientist behind an HTTP API.  Sure, he
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
  , {"rel": "favorites/create", "method": "post"}
  ]
}
```

Now, when you get a User, you may see these relations:

``` javascript
{ "_links":
  [ {"rel": "self", "href": "/users/1"}
  , {"rel": "update"}
  , {"rel": "favorites", "href": "/users/1/friends"}
  , {"rel": "favorites/create"}
  ]
}
```

The Sawyer agent should know that the 'destroy' relation is inaccessible
for some reason in the application. 
  
[faraday]: https://github.com/technoweenie/faraday

## Example?

See [example/client.rb](https://github.com/technoweenie/sawyer/blob/master/example/client.rb)

    # start the sinatra server
    $ ruby -rubygems ./example/server

    # run the client
    $ ruby -rubygems ./example/client

## TODO

* Resource schema validation
* Add a Sawyer::Response that gets returned from #request calls.
* Add the concept of errors, the world isn't perfect.
* Figure out if `Sawyer::MimeType` is even useful.
* More real-world examples to push Sawyer to its limit.

