#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'data_mapper'
require 'twitter_oauth'


use Rack::Auth::Basic, "Restricted Area" do |username, password|
  username == 'bianca' and password == 'whatthehell'
end

configure do
    enable :sessions
    set :session_secret, ENV['SESSION_SECRET']

end

before do
  puts "user before"
  puts @user
  puts "session user before"
  puts session[:user]
  @user = session[:user]
  puts "user after"
  puts @user
  puts "session user after"
  puts session[:user]
  @client = TwitterOAuth::Client.new(
    :consumer_key => ENV['TWITTER_CONSUMER_KEY'] ,
    :consumer_secret => ENV['TWITTER_CONSUMER_SECRET'],
    :token => session[:access_token],
    :secret => session[:secret_token]
  )
  puts "client"
  puts @client
  @rate_limit_status = @client.rate_limit_status
end


helpers do
    def next_highest(total,divisor) 
    	distance = divisor - (total%divisor)
        result = total + (distance)
        next_result = {
	        :distance => distance.to_i,
	        :result => comma_numbers(result,','),
    	}
        return next_result
    end

    def comma_numbers(number, delimiter = ',')
			number.to_s.reverse.gsub(%r{([0-9]{3}(?=([0-9])))}, "\\1#{delimiter}").reverse
	end
    
    def average_per_time(recent,period)

    	recent/period
    end

    def plural(number,word)
    	if number>1 
    		word = word + "s" 
    	end
    		return word
    end
end

get '/' do
  puts "get /"
  puts @user
  puts session[:user]
  redirect '/milestones' if @user
  @handle = "biancawelds"
  erb :index, layout: :"layouts/main"
end

	get '/index' do
		@handle = "biancawelds"
		erb :index, layout: :"layouts/main"
	end


post '/index' do
   @handle = params[:handle]
   @total = rand(15000)
   @averages_text = ""
   @far_away_text = "About "


   @next_1k = next_highest(@total,1000)
   @next_5k = next_highest(@total,5000)
   @next_10k = next_highest(@total,10000)


   @average_per_hour = average_per_time((@total/100),672)	   

   @average_per_day = average_per_time((@total/100),28)


   @average_per_week = average_per_time((@total/100),4)

   if @average_per_hour >= 1 
   	
	   	@averages_text = @averages_text + @average_per_hour.to_s + " " + plural(@average_per_hour,"tweet") + " per hour, " 
	   	@hours_from_1k = @next_1k[:distance]/@average_per_hour
	   	@hours_from_5k = @next_5k[:distance]/@average_per_hour
	   	@hours_from_10k = @next_10k[:distance]/@average_per_hour

	   	
	   		
	   	@hours_away_1k = @far_away_text + @hours_from_1k.to_s + " " + plural(@hours_from_1k.to_i,"hour") + " away"
	   	@hours_away_5k = @far_away_text + @hours_from_5k.to_s + " " + plural(@hours_from_5k.to_i,"hour") + " away" 
	   	@hours_away_10k = @far_away_text + @hours_from_10k.to_s + " " + plural(@hours_from_10k.to_i,"hour") + " away" 
	   	
   end
   if @average_per_day >= 1 
   		@averages_text = @averages_text + @average_per_day.to_s + " " + plural(@average_per_day,"tweet") + " per day, "
   		@days_from_1k = @next_1k[:distance]/@average_per_day 
	   	@days_from_5k = @next_5k[:distance]/@average_per_day
	   	@days_from_10k = @next_10k[:distance]/@average_per_day
	   	

   		@days_away_1k = @far_away_text + @days_from_1k.to_s + " " + plural(@days_from_1k.to_i,"day")  + " away"
	   	@days_away_5k = @far_away_text + @days_from_5k.to_s + " " + plural(@days_from_5k.to_i,"day")  + " away"
	   	@days_away_10k = @far_away_text + @days_from_10k.to_s + " " + plural(@days_from_10k.to_i,"day")  + " away"
   	end
   if @average_per_week >= 1 
   		
   		@weeks_from_1k = @next_1k[:distance]/@average_per_week
   		@weeks_from_5k = @next_5k[:distance]/@average_per_week
   		@weeks_from_10k = @next_10k[:distance]/@average_per_week

   		@averages_text = @averages_text + @average_per_week.to_s + " " + plural(@average_per_week,"tweet") + " over an entire week." 
   		@weeks_away_1k = @far_away_text + @weeks_from_1k.to_s + " " + plural(@weeks_from_1k.to_i,"week")  + " away"
	   	@weeks_away_5k = @far_away_text + @weeks_from_5k.to_s + " " + plural(@weeks_from_5k.to_i,"week")  + " away"
	   	@weeks_away_10k = @far_away_text + @weeks_from_10k.to_s + " " + plural(@weeks_from_10k.to_i,"week") + " away"
   	end

   	if @averages_text == ""
   		@averages_text = "Not enough tweets to calculate averages"
   	else
   		@averages_text = "and makes on average " + @averages_text
   	end

   erb :"content", layout: :"layouts/main"

end

get '/milestones' do
	#@tweets = @client.home_timeline
  puts "client"
  
  puts @client
  @total = @client.info['statuses_count']
  puts "total"
  puts @client.info['statuses_count']
 puts @total
  
  @averages_text = ""
   @far_away_text = "About "


   @next_1k = next_highest(@total,1000)
   puts "next 1k"
   puts @next_1k
   @next_5k = next_highest(@total,5000)
   puts "next 5k"
   puts @next_1k
   @next_10k = next_highest(@total,10000)
   puts "next 10k"
   puts @next_1k


   @average_per_hour = average_per_time((@total/100),672)    

   @average_per_day = average_per_time((@total/100),28)


   @average_per_week = average_per_time((@total/100),4)

   if @average_per_hour >= 1 
    
      @averages_text = @averages_text + @average_per_hour.to_s + " " + plural(@average_per_hour,"tweet") + " per hour, " 
      @hours_from_1k = @next_1k[:distance]/@average_per_hour
      @hours_from_5k = @next_5k[:distance]/@average_per_hour
      @hours_from_10k = @next_10k[:distance]/@average_per_hour

      
        
      @hours_away_1k = @far_away_text + @hours_from_1k.to_s + " " + plural(@hours_from_1k.to_i,"hour") + " away"
      @hours_away_5k = @far_away_text + @hours_from_5k.to_s + " " + plural(@hours_from_5k.to_i,"hour") + " away" 
      @hours_away_10k = @far_away_text + @hours_from_10k.to_s + " " + plural(@hours_from_10k.to_i,"hour") + " away" 
      
   end
   if @average_per_day >= 1 
      @averages_text = @averages_text + @average_per_day.to_s + " " + plural(@average_per_day,"tweet") + " per day, "
      @days_from_1k = @next_1k[:distance]/@average_per_day 
      @days_from_5k = @next_5k[:distance]/@average_per_day
      @days_from_10k = @next_10k[:distance]/@average_per_day
      

      @days_away_1k = @far_away_text + @days_from_1k.to_s + " " + plural(@days_from_1k.to_i,"day")  + " away"
      @days_away_5k = @far_away_text + @days_from_5k.to_s + " " + plural(@days_from_5k.to_i,"day")  + " away"
      @days_away_10k = @far_away_text + @days_from_10k.to_s + " " + plural(@days_from_10k.to_i,"day")  + " away"
    end
   if @average_per_week >= 1 
      
      @weeks_from_1k = @next_1k[:distance]/@average_per_week
      @weeks_from_5k = @next_5k[:distance]/@average_per_week
      @weeks_from_10k = @next_10k[:distance]/@average_per_week

      @averages_text = @averages_text + @average_per_week.to_s + " " + plural(@average_per_week,"tweet") + " over an entire week." 
      @weeks_away_1k = @far_away_text + @weeks_from_1k.to_s + " " + plural(@weeks_from_1k.to_i,"week")  + " away"
      @weeks_away_5k = @far_away_text + @weeks_from_5k.to_s + " " + plural(@weeks_from_5k.to_i,"week")  + " away"
      @weeks_away_10k = @far_away_text + @weeks_from_10k.to_s + " " + plural(@weeks_from_10k.to_i,"week") + " away"
    end

    if @averages_text == ""
      @averages_text = "Not enough tweets to calculate averages"
    else
      @averages_text = "and makes on average " + @averages_text
    end




	erb :milestones, layout: :"layouts/main"
end

get '/about' do
	erb :about, layout: :"layouts/main"

end

# store the request tokens and send to Twitter
get '/connect' do
	request_token = @client.request_token(
		:oauth_callback => ENV['CALLBACK_URL']
		)
  
	   session[:request_token] = request_token.token
     puts "session request token"
     puts session[:request_token]
	   session[:request_token_secret] = request_token.secret
     puts "session request token secret"
     puts session[:request_token_secret]
	   redirect request_token.authorize_url
   

end

# auth URL is called by twitter after the user has accepted the application
# this is configured on the Twitter application settings page
get '/auth' do
  # Exchange the request token for an access token.
  
  begin
    puts "session request token"
     puts session[:request_token]
     puts "session request token secret"
     puts session[:request_token_secret]
     puts "oauth verifier"
     puts params[:oauth_verifier]
     @access_token = @client.authorize(
      session[:request_token],
      session[:request_token_secret],
      :oauth_verifier => params[:oauth_verifier]
    )
     puts "access token"
     puts @access_token
     puts "access token token"
     puts @access_token.token
     puts "access token secret"
     puts @access_token.secret
   rescue OAuth::Unauthorized
   end
  
    puts @client.authorized?
   if @client.authorized?
       # Storing the access tokens so we don't have to go back to Twitter again
       # in this session.  In a larger app you would probably persist these details somewhere.
       session[:access_token] = @access_token.token
       puts "session access token"
        puts session[:access_token]
       session[:secret_token] = @access_token.secret
       puts "session secret token"
        puts session[:secret_token]
       session[:user] = true
       puts "session user"
        puts session[:user]
       redirect '/milestones'
     else
       redirect '/disconnect'
    end
end

get '/disconnect' do
  session[:user] = nil
  session[:request_token] = nil
  session[:request_token_secret] = nil
  session[:access_token] = nil
  session[:secret_token] = nil
  redirect '/'
end

get '/ping' do 
  'pong'
end


