require 'bundler'
Bundler.require

configure :development do
	DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
end

configure :production do
	DataMapper.setup(:default, ENV['HEROKU_POSTGRESQL_ROSE_URL'])
end



ENV['TWITTER_CONSUMER_KEY'] = 'FwW3TfTSLjWn3Ys9trQxZWgfF'
ENV['TWITTER_CONSUMER_SECRET'] = 'l4BmrNgso4WgdfdfFGICGwzABDyJ362p1DtxyWWe5jFbUuiyFA'
ENV['TWITTER_ACCESS_TOKEN'] = '172169556-QjWr6Ri3LNmaUklhnRhGVo6kjFcnFS6WI3cIKy3L'
ENV['TWITTER_ACCESS_TOKEN_SECRET'] = 'zxSWtXBJNREKJtK7V4roH9NbaMDHd9uLuAyI2gpm6nGwK'

ENV['CALLBACK_URL'] = 'http://localhost:9292/auth'

ENV['SESSION_SECRET'] = '*&(^B234'


require './main'


run Sinatra::Application