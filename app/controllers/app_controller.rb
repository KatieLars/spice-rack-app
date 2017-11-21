require 'sinatra/flash'
require 'tux'


class AppController < Sinatra::Base
  configure do
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "secret"
    register Sinatra::Flash
  end

  get '/' do #done
    erb :home
  end

  get '/login' do
    if logged_in?
      redirect "/#{current_user.slug}/home"
    else
      erb :login
    end
  end

  post '/login' do
    user = User.find_by(:username => params[:username])
    if user && !user.authenticate(params[:password])
      flash[:warning] = "Please enter a valid password"
      redirect '/login'
    elsif user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect "/#{user.slug}/home"
    else
      flash[:warning] = "Sorry! We couldn't find that username or password combination"
      redirect "/login"
    end
  end

  get '/signup' do
    if logged_in?
      redirect "/#{current_user.slug}/home"
    else
      erb :signup
    end
  end

  post '/signup' do
    if !logged_in?
      user = User.new(params)
      if user.save
        session[:user_id] = user.id
        redirect "/#{user.slug}/home"
      else
        flash[:error] = user.errors.full_messages.to_sentence
        redirect to '/signup'
      end
    else
      redirect to '/'
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

  get '/logout' do
    if logged_in?
      session.clear
      flash[:warning] = "You're logged out!"
      redirect '/'
    else
      flash[:warning] = "You are already logged out. Please log in again."
      redirect '/login'
    end
  end

  helpers do
   def logged_in?
     !!current_user
   end

   def current_user # setters/getter -> User Instance || nil
     #memoization
     @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
   end

   def delete_blank_values(params)
     params.delete_if{|k, v| v.empty? or v.instance_of?(Sinatra::IndifferentHash) && delete_blank_values(v).empty?}
   end
  end

end
