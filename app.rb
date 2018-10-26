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


post '/new' do
  p = Post.new params[:post1]
  p.save

  redirect to '/'
  erb "You typed: #{p}"
end

#  information about post

get '/details/:post_id' do
  

   @results = Post.find(params[:post_id])
   @post = params[:post_id]

   @comments = Comment.where(post_id: params[:post_id]) #find_by(post_id: params[:post_id])
# select commets to post
   #@comments = @db.execute 'select * from Comments where post_id = ? order by id', [post_id]

   erb :details
end

post '/details/:post_id' do

     c = Comment.new params[:comment]

     c.save
  
 redirect to '/details/' + params[:post_id]

end


