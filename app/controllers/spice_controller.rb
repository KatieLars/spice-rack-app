require 'sinatra/flash'

class SpiceController < AppController
  register Sinatra::Flash

  get '/spices' do #index
    @user = User.find_by_id(session[:user_id])
    if current_user && @user.spices.any?
      @spices = @user.spices
      erb :"spices/index"
    elsif current_user && @user.spices.none?

      flash.now[:empty_notification] = "Your spice rack is empty" #flash notification not working
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

get '/spices/new' do #new spice form
  @user = current_user
  if current_user
    erb :"spices/new"
  else
    redirect '/login'
  end
end

post '/spices/new' do #should create a new spice and recipe
  spice = Spice.create(params[:spice])
  if current_user
    spice.user_id = session[:user_id]
    spice.save
    recipe = Recipe.create(params[:recipe])
    recipe.user_id = session[:user_id]
    binding.pry

    redirect "/spices/#{spice.slug}"
  else
    redirect '/login'
  end
end

get '/spices/:slug' do #show
  slug_spice = Spice.find_by_slug(params[:slug])
  customer_spice = Spice.find_by(:user_id => session[:user_id], :name => slug_spice.name)

  if current_user && customer_spice #if the spice found by the slug and by the id is the same
    #sets the spice to an instance variable
    @spice = customer_spice
    erb :"spices/show"
  elsif current_user && !customer_spice
    #if customer logged in, but the slug spice is not in his/her rack
    flash[:spice_warning] = "This spice is not in your rack."
    erb :"spices/show"
  else #if user not logged in
    redirect '/login'
  end
end

end
