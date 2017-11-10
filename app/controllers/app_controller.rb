require 'sinatra/flash'
require 'tux'

class AppController < Sinatra::Base
  configure do
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "secret"
    register Sinatra::Flash
    FlavorParser.call
  end

  get '/' do #done
    erb :home
  end

  get '/login' do #if user not already logged in, displays login form
    if logged_in?
      @user = current_user
      redirect "/#{@user.slug}/home"
    else
      erb :login
    end
  end

  post '/login' do
    user = User.find_by(:username => params[:username])
    if params.detect {|k, v| v.empty?}
      empty_field = params.detect {|k, v| v.empty?}[0].to_s
      flash[:warning] = "Please enter #{empty_field}"
      redirect '/login'
    elsif user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect "/#{user.slug}/home"
    else #goes to sign up if can't find/authenticate user
      flash[:warning] = "Sorry! We couldn't find that username or password combination"
      redirect "/login"
    end
  end

  get '/signup' do
    if logged_in?
      @user = current_user
      redirect "/#{@user.slug}/home"
    else
      erb :signup
    end
  end

  post '/signup' do
    user = User.new(params)
    if params.detect {|k, v| v.empty?}
      empty_field = params.detect {|k, v| v.empty?}[0].to_s
      flash[:warning] = "Please enter #{empty_field}"
      redirect '/signup'
    elsif User.find_by(:username => params[:username])
      flash[:warning] = "Sorry! That username has already been used."
      redirect '/signup'
    elsif User.find_by(:email => params[:email])
      flash[:warning] = "A user with that email address already exists."
      redirect '/signup'
    elsif !User.find_by(:username => params[:username], :email => params[:email]) && user.save
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
     !!session[:user_id]
   end

   def current_user
     User.find(session[:user_id])
   end

   def repeat_spices_or_recipes(current_user_array, comp_obj)
     #detects blank or repeat spices or recipes, returns non-repeat obj
     current_user_array.detect {|obj| comp_obj.name.upcase == obj.name.upcase}
     #iterates over an array of spice/recipe objects associated with user, and
     #checks them against comp_obj to determine of the newly created comp_obj is a repeat
   end
  end

end
