class RecipeController < AppController

  get '/recipes' do
    @user = User.find_by_id(session[:user_id])
    if current_user && @user.recipes.any?
      @recipes = @user.recipes
      erb :"recipes/index"
    elsif current_user && @user.recipes.none?
      flash.now[:empty_notification] = "Your recipe book is empty" #flash notification not working
      erb :"recipes/index"
    else
      redirect "/"
    end
  end

  get '/recipes/new' do #new spice form
    @user = current_user
    if current_user
      erb :"recipes/new"
    else
      redirect '/login'
    end
  end


end
