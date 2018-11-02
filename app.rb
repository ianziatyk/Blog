require 'sinatra'
require 'sinatra/activerecord'


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

    # def reset_session
    #     @_request.reset_session
    #   end


get "/" do

@blogs = Blog.all
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
    if !session[:user_id]
        redirect"/"
    end

    current_blog
        if @blog.update(title:params[:title], content: params[:content] )
            redirect "/"
        else
            erb "/blogs/<%= @blog.id %>/edit"
        end
    end


    post "/destroy/:id" do
        @blog = Blog.find(params[:id])
        if !session[:user_id]
            redirect"/"
        end

        if session[:user_id] != @blog.user_id
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
        if user.password == params[:password]
        session[:user_id] = user.id
        redirect"/users/#{user.id}"
            
        elsif 
    
        if user && user.password == password
            
        end
       
    else
        redirect"/"
        erb :index
    end
end

post "/logout" do
    session[:user_id] = nil
    redirect"/"
end


get "/users/:id" do

    @user = User.find(params[:id])
    erb :user

end
        