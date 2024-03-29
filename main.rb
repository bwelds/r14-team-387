#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
require 'data_mapper'
require 'twitter'
require 'twitter_oauth'
require 'date'
require 'mailgun'


# use Rack::Auth::Basic, "Restricted Area" do |username, password|
#   username == 'bianca' and password == 'whatthehell'
# end

configure do
    enable :sessions
    set :session_secret, ENV['SESSION_SECRET']

end

Mailgun.configure do |config|
        config.api_key = ENV['MAILGUN_API_KEY']
        config.domain  = ENV['MAILGUN_DOMAIN ']
    end

before do
  
  # puts "session user"
  # puts session[:user]
  
      @client = TwitterOAuth::Client.new(
        :consumer_key => ENV['TWITTER_CONSUMER_KEY'] ,
        :consumer_secret => ENV['TWITTER_CONSUMER_SECRET'],
        :token => session[:access_token] ||  ENV['TWITTER_ACCESS_TOKEN'],
        :secret => session[:secret_token] || ENV['TWITTER_ACCESS_TOKEN_SECRET']
      )
      # puts "client"
      # puts @client
      @rate_limit_status = @client.rate_limit_status
  
  @twclient = Twitter::REST::Client.new do |config|
      config.consumer_key    = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
    end
    
  
end


helpers do
    def loggedin?
            session[:user]
    end

    

    def next_highest(total,divisor) 
    	distance = divisor - (total.to_i%divisor)
        result = total.to_i + distance
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

    def disconnect()
      session[:user] = nil
      session[:request_token] = nil
      session[:request_token_secret] = nil
      session[:access_token] = nil
      session[:secret_token] = nil
      
    end


    def plural(number,word)
    	if number>1 
    		word = word + "s" 
    	end
    		return word
    end
end

get '/' do
  # puts "get /"
  # puts session[:user]
  if loggedin?
    redirect '/milestones'
  else
    #redirect '/index'
    @handle = "railsrumble"
    erb :"welcome", layout: :"layouts/main"
  end
end

	get '/index.?:handle?' do
		@handle = params[:handle] || "railsrumble"

		erb :index, layout: :"layouts/main"
	end

  


post '/index' do
   @handle = params[:handle]
   if params[:handle].nil?
      erb :"content", layout: :"layouts/main"
    end

   @total = comma_numbers(@twclient.user(@handle)['statuses_count'],',')
   @tweets = @twclient.user_timeline(@handle, :count => 100)

   #puts @tweets.first.text
      newest = @tweets.first.created_at
     #puts @tweets.count
     #puts @tweets.last.text
     oldest = @tweets.last.created_at

    time_for_recent_tweets = difference = ((newest - oldest).abs).round

    hours_for_recent_tweets = (time_for_recent_tweets.to_f/(60*60)).ceil
    days_for_recent_tweets = (hours_for_recent_tweets.to_f/24).ceil
    weeks_for_recent_tweets = (days_for_recent_tweets.to_f/7).ceil

   @averages_text = ""
   @far_away_text = "About "


   @next_1k = next_highest(@total,1000)
   @next_5k = next_highest(@total,5000)
   if @next_1k == @next_5k then @next_5k = next_highest(@total,10000) end
   @next_10k = next_highest(@total,10000)
   if @next_5k == @next_10k then @next_10k = next_highest(@total,50000) end


   if hours_for_recent_tweets > 1 
     @average_per_hour = 100/hours_for_recent_tweets
    elsif hours_for_recent_tweets == 1
      @average_per_hour = 100
   else 
      @average_per_hour = 0 
  end  
    if days_for_recent_tweets > 1 
       @average_per_day = 100/days_for_recent_tweets 
     elsif days_for_recent_tweets == 1
         @average_per_day = 100*(hours_for_recent_tweets.to_f/24).ceil
     else 
      @average_per_day = 0 
    end
   if weeks_for_recent_tweets > 1 
    @average_per_week = 100/weeks_for_recent_tweets 
  elsif weeks_for_recent_tweets == 1
      @average_per_week = @average_per_day*7
  else 
    @average_per_week = 0 
  end


   if @average_per_hour >= 1 
   	
	   	@averages_text = @averages_text + @average_per_hour.to_s + " " + plural(@average_per_hour,"tweet") + " per hour, " 
	   	@hours_from_1k = @next_1k[:distance]/@average_per_hour
	   	@hours_from_5k = @next_5k[:distance]/@average_per_hour
	   	@hours_from_10k = @next_10k[:distance]/@average_per_hour

	   	
	   		
	   	@hours_away_1k = @far_away_text + comma_numbers(@hours_from_1k,',').to_s + " " + plural(@hours_from_1k.to_i,"hour") + " away"
	   	@hours_away_5k = @far_away_text + comma_numbers(@hours_from_5k,',').to_s + " " + plural(@hours_from_5k.to_i,"hour") + " away" 
	   	@hours_away_10k = @far_away_text + comma_numbers(@hours_from_10k,',').to_s + " " + plural(@hours_from_10k.to_i,"hour") + " away" 
	   	
   end
   if @average_per_day >= 1 
   		@averages_text = @averages_text + @average_per_day.to_s + " " + plural(@average_per_day,"tweet") + " per day, "
   		@days_from_1k = @next_1k[:distance]/@average_per_day 
	   	@days_from_5k = @next_5k[:distance]/@average_per_day
	   	@days_from_10k = @next_10k[:distance]/@average_per_day
	   	

   		@days_away_1k = @far_away_text + comma_numbers(@days_from_1k,',').to_s + " " + plural(@days_from_1k.to_i,"day")  + " away"
	   	@days_away_5k = @far_away_text + comma_numbers(@days_from_5k,',').to_s + " " + plural(@days_from_5k.to_i,"day")  + " away"
	   	@days_away_10k = @far_away_text + comma_numbers(@days_from_10k,',').to_s + " " + plural(@days_from_10k.to_i,"day")  + " away"
   	end
   if @average_per_week >= 1 
   		
   		@weeks_from_1k = @next_1k[:distance]/@average_per_week
   		@weeks_from_5k = @next_5k[:distance]/@average_per_week
   		@weeks_from_10k = @next_10k[:distance]/@average_per_week

   		@averages_text = @averages_text + comma_numbers(@average_per_week,',').to_s + " " + plural(@average_per_week,"tweet") + " over an entire week." 
   		@weeks_away_1k = @far_away_text + comma_numbers(@weeks_from_1k,',').to_s + " " + plural(@weeks_from_1k.to_i,"week")  + " away"
	   	@weeks_away_5k = @far_away_text + comma_numbers(@weeks_from_5k,',').to_s + " " + plural(@weeks_from_5k.to_i,"week")  + " away"
	   	@weeks_away_10k = @far_away_text + comma_numbers(@weeks_from_10k,',').to_s + " " + plural(@weeks_from_10k.to_i,"week") + " away"
   	end

   	if @averages_text == ""
   		@averages_text = "Not enough tweets to calculate averages"
   	else
   		@averages_text = "and makes on average " + @averages_text
   	end
    @client = @twclient
   erb :"content", layout: :"layouts/main"

end

get '/milestones' do

  if !loggedin?
    redirect '/index'
  else
    
	#@tweets = @client.home_timeline
  # puts "client"
  
  # puts @client
  @total = comma_numbers(@client.info['statuses_count'],',')
  @name = @client.info['name']
  #@profile_image = "<img class='profile' src='" + @client.info['profile_image_url'] + "' >"
  
  
   #@tweets = @client.user_timeline(:count => 100)
   @tweets = @client.user_timeline(:count => 100)

    newest = time_for(@tweets.first['created_at'])

    oldest = time_for(@tweets.last['created_at'])



     
     #puts DateTime.parse(newest)
     #puts @tweets.last.text
    #puts oldest = @tweets.last.created_at
    #puts DateTime.parse(oldest)
    #time_for_recent_tweets = ((DateTime.parse(newest) - DateTime.parse(oldest)).abs).round
    time_for_recent_tweets = ((newest - oldest).abs).round
    hours_for_recent_tweets = (time_for_recent_tweets.to_f/(60*60)).ceil
    days_for_recent_tweets = (hours_for_recent_tweets.to_f/24).ceil
    weeks_for_recent_tweets = (days_for_recent_tweets.to_f/7).ceil

   @averages_text = ""
   @far_away_text = "About "


   @next_1k = next_highest(@total,1000)
   @next_5k = next_highest(@total,5000)
   if @next_1k == @next_5k then @next_5k = next_highest(@total,10000) end
   @next_10k = next_highest(@total,10000)
   if @next_5k == @next_10k then @next_10k = next_highest(@total,50000) end


   if hours_for_recent_tweets > 1 
     @average_per_hour = 100/hours_for_recent_tweets
    elsif hours_for_recent_tweets == 1
      @average_per_hour = 100
   else 
      @average_per_hour = 0 
  end  
    if days_for_recent_tweets > 1 
       @average_per_day = 100/days_for_recent_tweets 
     elsif days_for_recent_tweets == 1
         @average_per_day = 100*(hours_for_recent_tweets.to_f/24).ceil
     else 
      @average_per_day = 0 
    end
   if weeks_for_recent_tweets > 1 
    @average_per_week = 100/weeks_for_recent_tweets 
  elsif weeks_for_recent_tweets == 1
      @average_per_week = @average_per_day*7
  else 
    @average_per_week = 0 
  end

   
   if @average_per_hour >= 1 
    
      @averages_text = @averages_text + @average_per_hour.to_s + " " + plural(@average_per_hour,"tweet") + " per hour, " 
      @hours_from_1k = @next_1k[:distance]/@average_per_hour
      @hours_from_5k = @next_5k[:distance]/@average_per_hour
      @hours_from_10k = @next_10k[:distance]/@average_per_hour

      
        
      @hours_away_1k = @far_away_text + comma_numbers(@hours_from_1k,',').to_s + " " + plural(@hours_from_1k.to_i,"hour") + " away"
      @hours_away_5k = @far_away_text + comma_numbers(@hours_from_5k,',').to_s + " " + plural(@hours_from_5k.to_i,"hour") + " away" 
      @hours_away_10k = @far_away_text + comma_numbers(@hours_from_10k,',').to_s + " " + plural(@hours_from_10k.to_i,"hour") + " away" 
      
   end
   if @average_per_day >= 1 
      @averages_text = @averages_text + @average_per_day.to_s + " " + plural(@average_per_day,"tweet") + " per day, "
      @days_from_1k = @next_1k[:distance]/@average_per_day 
      @days_from_5k = @next_5k[:distance]/@average_per_day
      @days_from_10k = @next_10k[:distance]/@average_per_day
      

      @days_away_1k = @far_away_text + comma_numbers(@days_from_1k,',').to_s + " " + plural(@days_from_1k.to_i,"day")  + " away"
      @days_away_5k = @far_away_text + comma_numbers(@days_from_5k,',').to_s + " " + plural(@days_from_5k.to_i,"day")  + " away"
      @days_away_10k = @far_away_text + comma_numbers(@days_from_10k,',').to_s + " " + plural(@days_from_10k.to_i,"day")  + " away"
    end
   if @average_per_week >= 1 
      
      @weeks_from_1k = @next_1k[:distance]/@average_per_week
      @weeks_from_5k = @next_5k[:distance]/@average_per_week
      @weeks_from_10k = @next_10k[:distance]/@average_per_week

      @averages_text = @averages_text + comma_numbers(@average_per_week,',').to_s + " " + plural(@average_per_week,"tweet") + " over an entire week." 
      @weeks_away_1k = @far_away_text + comma_numbers(@weeks_from_1k,',').to_s + " " + plural(@weeks_from_1k.to_i,"week")  + " away"
      @weeks_away_5k = @far_away_text + comma_numbers(@weeks_from_5k,',').to_s + " " + plural(@weeks_from_5k.to_i,"week")  + " away"
      @weeks_away_10k = @far_away_text + comma_numbers(@weeks_from_10k,',').to_s + " " + plural(@weeks_from_10k.to_i,"week") + " away"
    end

    if @averages_text == ""
      @averages_text = "Not enough tweets to calculate averages"
    else
      @averages_text = "and make on average " + @averages_text
    end




	erb :milestones, layout: :"layouts/main"

  end
end

get '/email' do
  erb :email, layout: :"layouts/main"
end


get '/about' do
	erb :about, layout: :"layouts/main"

end

get '/contact' do
        erb :"contact", layout: :"layouts/main"
    end

    post '/contact' do
        name = params[:name] || @client.info['name']
        email = params[:email]
        comment = params[:comment]
        
        
        @mailgun = Mailgun()

        parameters = {
            :to => ENV['CONTACT_MAIL']  = 'bwelds@gmail.com',
            :from => email,
            :subject => "Miletweets Contact from #{name}",
            :text => comment
        }
        
        sent = @mailgun.messages.send_email(parameters)? (redirect '/email') : (redirect '/error')
        
    end

# store the request tokens and send to Twitter
get '/connect' do
	request_token = @client.request_token(
		:oauth_callback => ENV['CALLBACK_URL']
		)
  
	   session[:request_token] = request_token.token
     # puts "session request token"
     # puts session[:request_token]
	   session[:request_token_secret] = request_token.secret
     # puts "session request token secret"
     # puts session[:request_token_secret]
	   redirect request_token.authorize_url
   

end

# auth URL is called by twitter after the user has accepted the application
# this is configured on the Twitter application settings page
get '/auth' do
  # Exchange the request token for an access token.
  
  begin
    # puts "session request token"
    #  puts session[:request_token]
    #  puts "session request token secret"
    #  puts session[:request_token_secret]
    #  puts "oauth verifier"
    #  puts params[:oauth_verifier]
     @access_token = @client.authorize(
      session[:request_token],
      session[:request_token_secret],
      :oauth_verifier => params[:oauth_verifier]
    )
     # puts "access token"
     # puts @access_token
     # puts "access token token"
     # puts @access_token.token
     # puts "access token secret"
     # puts @access_token.secret
   rescue OAuth::Unauthorized
   end
  
    puts @client.authorized?
   if @client.authorized?
       # Storing the access tokens so we don't have to go back to Twitter again
       # in this session.  In a larger app you would probably persist these details somewhere.
       session[:access_token] = @access_token.token
       # puts "session access token"
       #  puts session[:access_token]
       session[:secret_token] = @access_token.secret
       # puts "session secret token"
       #  puts session[:secret_token]
       session[:user] = true
       # puts "session user"
       #  puts session[:user]
       redirect '/milestones'
     else
       redirect '/unauthorized'
    end
end

get '/unauthorized' do
  disconnect
  erb :"unauthorized", layout: :"layouts/main"
end

#authentication failure
  get '/auth/failure' do
      redirect '/error'
  end

get '/disconnect' do
  disconnect
  redirect '/'
end

get '/ping' do 
  'pong'
end

get '/error' do
    erb :"error", layout: :"layouts/main"
end

not_found do
    erb :"notfound", layout: :"layouts/main"
end

get '/back' do
  redirect back
end


















