require 'rubygems'
require 'sinatra'

get '/' do
  erb :"index", layout: :"layouts/main"
end