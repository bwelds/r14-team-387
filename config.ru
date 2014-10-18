require './main'

configure :development do
	DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
end

configure :production do
	DataMapper.setup(:default, ENV['HEROKU_POSTGRESQL_ROSE_URL'])
end


run Sinatra::Application