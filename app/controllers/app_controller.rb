class AppController < Sinatra::Base
  configure do
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "secret"
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
      redirect '/user'
    else
      erb :"users/signup"
    end
  end

  post '/signup' do

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
