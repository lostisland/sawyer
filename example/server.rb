require 'sinatra'
require 'json'

get '/' do
  app_type

  body JSON.dump({
    :_links => {
      :users  => {:href => "/users", :method => 'get,post'},
      :nigiri => {:href => "/nigiri"}
    }
  })
end

def app_type
  content_type "application/vnd.sushihub+json"
end

users = [
  {:id => 1, :login => 'sawyer',  :created_at => Time.utc(2004, 9, 22),
   :_links => {
     :self               => {:href => '/users/sawyer'},
     :favorites          => {:href => '/users/sawyer/favorites', :method => 'get,post'}
   }},
  {:id => 2, :login => 'faraday', :created_at => Time.utc(2004, 12, 22),
   :_links => {
     :self               => {:href => '/users/faraday'},
     :favorites          => {:href => '/users/faraday/favorites', :method => 'get,post'}
   }}
]

nigiri = [
  {:id => 1, :name => 'sake',  :fish => 'salmon',
   :_links => {
     :self => {:href => '/nigiri/sake'}
   }},
  {:id => 2, :name => 'unagi', :fish => 'eel',
   :_links => {
     :self => {:href => '/nigiri/unagi'}
   }}
]

get '/users' do
  app_type

  body JSON.dump users
end

new_users = {}
post '/users' do
  if env['CONTENT_TYPE'].to_s !~ /json/i
    halt 400, "Needs JSON"
  end

  app_type

  hash = JSON.load request.body.read
  new_users[hash[:login]] = hash
  
  headers "Location" => "/users/#{hash[:login]}"
  status 201
  body JSON.dump hash.update(
    :id => 3,
    :created_at => Time.now.utc.xmlschema,
    :_links => {
      :self              => {:href => "/users/#{hash[:login]}"},
      :favorites         => {:href => "/users/#{hash[:login]}/favorites", :method => 'get,post'}
    }
  )
end

get '/users/:login' do
  headers 'Content-Type' => app_type
  if hash = users.detect { |u| u[:login] == params[:login] }
    body JSON.dump hash
  else
    halt 404
  end
end

get '/users/:login/favorites' do
  app_type

  case params[:login]
  when users[0][:login] then body JSON.dump([nigiri[0]])
  when users[1][:login] then body JSON.dump([])
  else halt 404
  end
end

post '/users/:login/favorites' do
  if params[:id].to_i > 0
    halt 201
  else
    halt 422
  end
end

get '/nigiri' do
  app_type

  body JSON.dump nigiri
end

get '/nigiri/:name' do
  app_type

  if hash = nigiri.detect { |n| n[:name] == params[:name] }
    body JSON.dump hash
  else
    halt(404)
  end
end

