require 'sinatra'
require 'yajl'

get '/' do
  app_type

  Yajl.dump({
    :_links => [
      {:rel => 'users',  :schema => "/schema/user"},
      {:rel => 'nigiri', :schema => "/schema/nigiri"}
    ]
  }, :pretty => true)
end

def app_type
  content_type "application/vnd.sushihub+json"
end

users = [
  {:id => 1, :login => 'sawyer',  :created_at => Time.utc(2004, 9, 22),
   :_links => [
     {:rel => :self,      :href => '/users/sawyer'},
     {:rel => :favorites, :href => '/users/sawyer/favorites'},
     {:rel => 'favorites/create'}
   ]},
  {:id => 2, :login => 'faraday', :created_at => Time.utc(2004, 12, 22),
   :_links => [
     {:rel => :self,      :href => '/users/faraday'},
     {:rel => :favorites, :href => '/users/faraday/favorites'},
     {:rel => 'favorites/create'}
   ]}
]

nigiri = [
  {:id => 1, :name => 'sake',  :fish => 'salmon',
   :_links => [
     {:rel => :self, :href => '/nigiri/sake'}
   ]},
  {:id => 2, :name => 'unagi', :fish => 'eel',
   :_links => [
     {:rel => :self, :href => '/nigiri/unagi'}
   ]}
]

get '/users' do
  app_type

  Yajl.dump users, :pretty => true
end

new_users = {}
post '/users' do
  if env['CONTENT_TYPE'].to_s !~ /json/i
    halt 400, "Needs JSON"
  end

  app_type

  hash = Yajl.load request.body.read, :symbolize_keys => true
  new_users[hash[:login]] = hash
  
  headers "Location" => "/users/#{hash[:login]}"
  status 201
  Yajl.dump hash.update(
    :id => 3,
    :created_at => Time.now.utc.xmlschema,
    :_links => [
      {:rel => :self, :href => "/users/#{hash[:login]}"},
      {:rel => :favorites, :href => "/users/#{hash[:login]}/favorites"},
      {:rel => 'favorites/create'}
    ]
  ), :pretty => true
end

get '/users/:login' do
  headers 'Content-Type' => app_type
  if hash = users.detect { |u| u[:login] == params[:login] }
    Yajl.dump hash, :pretty => true
  else
    halt 404
  end
end

get '/users/:login/favorites' do
  app_type

  case params[:login]
  when users[0][:login] then Yajl.dump([nigiri[0]], :pretty => true)
  when users[1][:login] then Yajl.dump([], :pretty => true)
  else halt 404
  end
end

get '/nigiri' do
  app_type

  Yajl.dump nigiri, :pretty => true
end

get '/nigiri/:name' do
  app_type

  if hash = nigiri.detect { |n| n[:name] == params[:name] }
    Yajl.dump hash, :pretty => true
  else
    halt(404)
  end
end

get '/schema' do
  app_type

  Yajl.dump([
    {:_links => {:self => '/schema/user'}},
    {:_links => {:self => '/schema/nigiri'}}
  ], :pretty => true)
end

get '/schema/:type' do
  app_type

  path = File.expand_path("../#{params[:type]}.schema.json", __FILE__)
  if File.exist?(path)
    headers 'content-type' => content_type
    IO.read path
  else
    halt 404
  end
end

