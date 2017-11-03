class SpiceController < AppController

  get '/spices' do #index
    @user = User.find_by_id(session[:user_id])
    if logged_in?
      @spices = @user.spices
      erb :"spices/index"
    else
      redirect "/"
    end
  end

  get '/spices/flavors' do #index by flavor
    @user = current_user
    if current_user
      @flavors = current_user.flavors
      erb :"spices/flavors"
    else
      redirect '/login'
    end
  end

get '/spices/:slug' do #show
  @spice = Spice.find_by_slug(params[:slug])
  if current_user
    erb :"spices/show"
  else
    redirect '/login'
  end
end

get '/spices/new' do #new spice form
  if current_user
    erb :"spices/new"
  else
    redirect '/login'
  end
end

end
