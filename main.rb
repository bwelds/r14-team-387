require 'rubygems'
require 'sinatra'

use Rack::Auth::Basic, "Restricted Area" do |username, password|
  username == 'bianca' and password == 'whatthehell'
end

get '/' do
  erb :"index", layout: :"layouts/main"
end