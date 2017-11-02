require 'sinatra/flash'

class AppController < Sinatra::Base
  configure do
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "secret"
    register Sinatra::Flash
  end

  get '/' do
    erb :home
  end

  get '/login' do
    if !logged_in?
      erb :login
    else
      @user = current_user
      redirect "/#{@user.slug}/home"
    end
  end

  post '/login' do
    user = User.find_by(:username => params[:username])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect "/#{user.slug}/home"
    else
      redirect "/signup"
    end
  end

  get '/signup' do
    if logged_in?
      @user = current_user
      redirect "/#{@user.slug}/home"
    else
      erb :"users/signup"
    end
  end

  post '/signup' do
    user = User.new(params)
    if empty_field = params.detect {|k, v| v.empty?}[0].to_s
      flash[:warning] = "Please enter #{empty_field}"
      redirect '/signup'
    elsif User.find_by(:username => params[:username])
      flash[:warning] = "Sorry! That username has already been used."
      redirect '/signup'
    elsif !User.find_by(:username => params[:username]) && user.save
      session[:user_id] = user.id
      redirect "/#{user.slug}/home"
    end
  end

  get '/:slug/home' do
    @user = User.find_by_slug(params[:slug])
    if current_user
      erb :"users/home"
    else
      redirect "/login"
    end
  end

  helpers do
   def logged_in?
     !!session[:user_id]
   end

   def current_user
     User.find(session[:user_id])
   end
  end

end
