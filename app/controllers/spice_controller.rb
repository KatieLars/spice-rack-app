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

  get '/spices/flavors' do #will this get all spice from any user or just the spices from the user profile?
    @user = current_user
    if current_user
      @flavors = current_user.flavors
      erb :"spices/flavors"
    else
      redirect '/login'
    end
  end

  


end
