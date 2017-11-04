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
  slug_spice = Spice.find_by_slug(:slug)
  customer_spice = Spice.find_by(:user_id => session[:user_id])
  if current_user && (slug_spice == customer_spice) #if the spice found by the slug and by the id is the same
    #sets the spice to an instance variable
    @spice = slug_spice
    erb :"spices/show"
  elsif current_user && !(slug_spice == customer_spice)
    #if customer logged in, but the slug spice is not in his/her rack
    flash[:warning] = "This spice is not in your rack."
  else #if user not logged in
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

get

end
