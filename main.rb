require 'rubygems'
require 'sinatra'

use Rack::Auth::Basic, "Restricted Area" do |username, password|
  username == 'bianca' and password == 'whatthehell'
end


helpers do
        def next_highest(total,divisor)
            result = total + (divisor - (total%divisor))
            return comma_numbers(result,',')
        end

        def comma_numbers(number, delimiter = ',')
  			number.to_s.reverse.gsub(%r{([0-9]{3}(?=([0-9])))}, "\\1#{delimiter}").reverse
		end
        

end

["/", "/index/?"].each do |path|
      get path do
      	@handle = "biancawelds"
        erb :"index", layout: :"layouts/main"
      end
    end

post '/index' do
	   @handle = params[:handle]
	   @total = rand(15000)
	   
	   @next_1k = next_highest(@total,1000)
	   @next_5k = next_highest(@total,5000)
	   @next_10k = next_highest(@total,10000)



	   erb :"content", layout: :"layouts/main"


end

