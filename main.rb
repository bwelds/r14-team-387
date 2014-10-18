require 'rubygems'
require 'sinatra'

use Rack::Auth::Basic, "Restricted Area" do |username, password|
  username == 'bianca' and password == 'whatthehell'
end




["/", "/index/?"].each do |path|
      get path do
      	@handle = "biancawelds"
        erb :"index", layout: :"layouts/main"
      end
    end

post '/index' do
	   @handle = params[:handle]
	   erb :"content", layout: :"layouts/main"
	   

end

