require 'sinatra'
require 'yajl'

get '/' do
  Yajl.dump({
    :name => 'sushihub',
    :_links => {
      :users  => '/users',
      :nigiri => '/nigiri'
    }
  }, :pretty => true)
end

users = [
  {:id => 1, :login => 'sawyer',  :created_at => Time.utc(2004, 9, 22),
   :_links => {:self => '/users/sawyer', :favorites => '/users/sawyer/favorites'}},
  {:id => 2, :login => 'faraday', :created_at => Time.utc(2004, 12, 22),
   :_links => {:self => '/users/faraday', :favorites => '/users/faraday/favorites'}}
]

nigiri = [
  {:id => 1, :name => 'sake',  :fish => 'salmon',
   :_links => {:self => '/nigiri/sake'}},
  {:id => 2, :name => 'unagi', :fish => 'eel',
   :_links => {:self => '/nigiri/unagi'}}
]

get '/users' do
  headers 'content-type' => 'application/vnd.sushihub.user+json; profile=/schema/user'
  Yajl.dump users, :pretty => true
end

get '/users/:login' do
  headers 'content-type' => 'application/vnd.sushihub.user+json; profile=/schema/user'
  if hash = users.detect { |u| u[:login] == params[:login] }
    Yajl.dump hash, :pretty => true
  else
    halt 404
  end
end

get '/users/:login/favorites' do
  headers 'content-type' => 'application/vnd.sushihub.nigiri+json; profile=/schema/nigiri'
  case params[:login]
  when users[0][:login] then Yajl.dump([nigiri[0]], :pretty => true)
  when users[1][:login] then Yajl.dump([], :pretty => true)
  else halt 404
  end
end

get '/nigiri' do
  headers 'content-type' => 'application/vnd.sushihub.nigiri+json; profile=/schema/nigiri'
  Yajl.dump nigiri, :pretty => true
end

get '/nigiri/:name' do
  headers 'content-type' => 'application/vnd.sushihub.nigiri+json; profile=/schema/nigiri'
  if hash = nigiri.detect { |n| n[:name] == params[:name] }
    Yajl.dump hash, :pretty => true
  else
    halt(404)
  end
end

get '/schema' do
  Yajl.dump([
    {:content_type => 'application/vnd.sushihub.user+json',   :_links => {:self => '/schema/user'}},
    {:content_type => 'application/vnd.sushihub.nigiri+json', :_links => {:self => '/schema/nigiri'}}
  ], :pretty => true)
end

get '/schema/:type' do
  path = File.expand_path("../#{params[:type]}.schema.json", __FILE__)
  if File.exist?(path)
    headers 'content-type' => 'application/json'
    IO.read path
  else
    halt 404
  end
end

