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
        
        def average_per_time(recent,period)

        	recent/period

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
	   @averages = "and makes on average "
	   
	   @next_1k = next_highest(@total,1000)
	   @next_5k = next_highest(@total,5000)
	   @next_10k = next_highest(@total,10000)

	   @average_per_hour = average_per_time(@total/100,672)
	   @average_per_day = average_per_time(@total/100,28)
	   @average_per_week = average_per_time(@total/100,4)

	   if @average_per_hour >= 1 then @averages = @averages + @average_per_hour.to_s+" tweets per hour, " end
	   if @average_per_day >= 1 then @averages = @averages + @average_per_day.to_s+" tweets per day, " end
	   if @average_per_week >= 1 then @averages =  @averages + " and "+@average_per_week.to_s+" tweets over an entire week." end


	   erb :"content", layout: :"layouts/main"


end

