require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
  @db = SQLite3::Database.new './leprosorium.db'
  @db.results_as_hash = true
end

before do
  init_db
end

configure do
  init_db # before не вызывается в этом методе
  enable :sessions
  @db.execute 'CREATE TABLE IF NOT EXISTS Posts 
  (
    id  INTEGER PRIMARY KEY AUTOINCREMENT,
    created_date  TEXT,
    content TEXT
  )'
end



helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end
end

before '/secure/*' do
  unless session[:identity]
    session[:previous_url] = request.path
    @error = 'Sorry, you need to be logged in to visit ' + request.path
    halt erb(:login_form)
  end
end

get '/new' do
  erb :new
end

get '/' do
  erb 'Can you handle a <a href="/secure/place">secret</a>?'
end

get '/login/form' do
  erb :login_form
end

post '/login/attempt' do
  session[:identity] = params['username']
  where_user_came_from = session[:previous_url] || '/'
  redirect to where_user_came_from
end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Logged out</div>"
end

get '/secure/place' do
  erb 'This is a secret place that only <%=session[:identity]%> has access to!'
end

post '/new' do
  @content = params[:content]

  if @content.length <= 0
    @error = "Type text"
    return erb :new
  end
  erb "You typed: #{@content}"
end

