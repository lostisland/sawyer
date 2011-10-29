require 'sinatra'
require 'yajl'

get '/' do
  app_type

  Yajl.dump({
    :_links => {
      :users          => {:_href => "/users"},
      :'users/create' => {:_href => "/users", :_method => 'post'},
      :nigiri         => {:_href => "/nigiri"}
    }
  }, :pretty => true)
end

def app_type
  content_type "application/vnd.sushihub+json"
end

users = [
  {:id => 1, :login => 'sawyer',  :created_at => Time.utc(2004, 9, 22),
   :_links => {
     :self               => {:_href => '/users/sawyer'},
     :favorites          => {:_href => '/users/sawyer/favorites'},
     :'favorites/create' => {:_href => '/users/sawyer/favorites', :_method => :post}
   }},
  {:id => 2, :login => 'faraday', :created_at => Time.utc(2004, 12, 22),
   :_links => {
     :self               => {:_href => '/users/faraday'},
     :favorites          => {:_href => '/users/faraday/favorites'},
     :'favorites/create' => {:_href => '/users/faraday/favorites', :_method => :post}
   }}
]

nigiri = [
  {:id => 1, :name => 'sake',  :fish => 'salmon',
   :_links => {
     :self => {:_href => '/nigiri/sake'}
   }},
  {:id => 2, :name => 'unagi', :fish => 'eel',
   :_links => {
     :self => {:_href => '/nigiri/unagi'}
   }}
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
    :_links => {
      :self              => {:_href => "/users/#{hash[:login]}"},
      :favorites         => {:_href => "/users/#{hash[:login]}/favorites"},
      'favorites/create' => {:_href => "/users/#{hash[:login]}/favorites", :_method => :post}
    }
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

