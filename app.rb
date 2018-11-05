require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/flash'


set :database, "sqlite3:second.sqlite3"
set :sessions, true

require './models'



def current_blog
    @blog = Blog.find(params[:id])
end


def current_user
    if(session[:user_id])
        @currentuser = User.find(session[:user_id])
    end
end



get "/" do
    @blogs = Blog.all
   
    if session[:user_id]
        flash[:notice] = 'Welcome'
    end
    
    if !session[:user_id]
        flash[:notice] = "Welcome to BlogDuck! Please log-in or Create a new Login "
        
    end


erb :index

end

get "/new" do

    erb :new
end

post "/create_blog" do

    if !session[:user_id]
        redirect"/"
    end
    title = params[:title]
    content = params[:content]

    user = User.find(session[:user_id])

    Blog.create(title:title , content: content, user_id: user.id )
    redirect "/"
end

get "/blogs/:id" do
    
    @blog = Blog.find(params[:id])

    erb :show
end

get "/blogs/:id/edit" do
    
    current_blog
    
    erb :edit
    
end

post "/update/:id" do
    current_blog
   
    if !session[:user_id]
        redirect"/"
    end

    if session[:user_id] != @blog.user_id
        flash[:notice] = "you do not have permission to cahnge this blog "
            redirect"/"
        end


    
        if @blog.update(title:params[:title], content: params[:content] )
            redirect "/"
        else
            erb "/blogs/@blog.id/edit"
        end
    end


    post "/destroy/:id" do
        @blog = Blog.find(params[:id])
        if !session[:user_id]
            redirect"/"
            
        end

        if session[:user_id] != @blog.user_id
            flash[:notice] = "you do not have permission to delete this is not your blog"
                redirect"/"
          
         else

            if @blog.destroy 
                redirect"/"
            end
        end
    end


        post '/signup' do
            username = params[:username]
            password = params[:password]

            user = User.new(username: username , password: password)
            if user.save
                
                redirect "/"
            else
                erb :index
        end
    end

    get "/hello" do
        erb :hello
    end


    post "/login" do
        user = User.where(username: params[:username]).first
        password = params[:password]
        if user && user.password == password
        session[:user_id] = user.id
        # redirect"/users/#{user.id}"
        redirect "/"
        end

        if  user && user.password != password
            flash[:alert] = 'log in didnt work'
            redirect"/"
           
        else
            flash[:alert] = 'log in no exist'
            redirect"/"
         
        end
    
        erb :index
    
end

post "/logout" do
    session[:user_id] = nil
    flash[:notice] = "Goodbye!"
    redirect"/"
end


get "/users/:id" do

    @user = User.find(params[:id])
     if !session[:user_id]
        redirect"/"
    end
    
    erb :user

end

get "/all_users" do

    @user=User.all

    if !session[:user_id]
        redirect"/"
    end

    erb :all_users

end

post "/destroy/user/:id" do

    if !session[:user_id]
        redirect"/"
    end
    
 session[:user_id] =nil
 @user = User.find(params[:id])
 @user.blogs.each do |x|
  x.destroy
 end
 
 @user.destroy
 redirect "/"
end