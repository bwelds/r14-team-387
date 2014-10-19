require 'bundler'
Bundler.require

configure :development do
	DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
	ENV['CALLBACK_URL'] = 'http://localhost:9292/auth'
end

configure :production do
	DataMapper.setup(:default, ENV['HEROKU_POSTGRESQL_ROSE_URL'])
	ENV['CALLBACK_URL'] = 'http://bdw.r14.railsrumble.com/auth'
end



ENV['TWITTER_CONSUMER_KEY'] = 'FwW3TfTSLjWn3Ys9trQxZWgfF'
ENV['TWITTER_CONSUMER_SECRET'] = 'l4BmrNgso4WgdfdfFGICGwzABDyJ362p1DtxyWWe5jFbUuiyFA'
ENV['TWITTER_ACCESS_TOKEN'] = '172169556-QjWr6Ri3LNmaUklhnRhGVo6kjFcnFS6WI3cIKy3L'
ENV['TWITTER_ACCESS_TOKEN_SECRET'] = 'zxSWtXBJNREKJtK7V4roH9NbaMDHd9uLuAyI2gpm6nGwK'


ENV['MAILGUN_API_KEY'] = 'key-889yy6870dgb2sym3fw-curxsnmlgcc1'
ENV['MAILGUN_DOMAIN '] = 'sandbox81136.mailgun.org'



ENV['CONTACT_MAIL']  = 'bwelds@gmail.com'


ENV['SESSION_SECRET'] = '*&(^B234'


require './main'


run Sinatra::Application