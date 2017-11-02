class SpiceController < AppController

  get '/spices' do
    @user = User.find_by_id(session[:user_id])
    if logged_in?
      @spices = @user.spices
      erb :"spices/index"
    else
      redirect "/"
    end
  end

  get '/spices/flavors' do
    if logged_in?
      #should group spices by pre-uploaded flavor profiles
    end
  end


end
