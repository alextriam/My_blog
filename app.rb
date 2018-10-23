require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'
require 'sinatra/activerecord'

set :database, "sqlite3:leprosorium.db"

class Post < ActiveRecord::Base
  has_many :comments, dependent: :destroy
end

class Comment < ActiveRecord::Base
  belongs_to :post
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
    # list posts from darabase
  @results = Post.all # 'select * from Posts order by id desc'

  erb :index 
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
  p = Post.new params[:post1]
  p.save

  redirect to '/'
  erb "You typed: #{p}"
end

#  information about post

get '/details/:post_id' do
  post_id = params[:post_id]

   @results = Post.find(post_id)
   c = Comment.new params[:content]
   c.save
   
# select commets to post
   #@comments = @db.execute 'select * from Comments where post_id = ? order by id', [post_id]

   erb :details
end

post '/details/:post_id' do
  post_id = Post.find([:post_id])
  content = params[:content]

  if content.size < 1
    @error = 'Введите текст комментария'
    redirect to '/details/' + post_id
  end




 redirect to '/details/' + post_id



end


