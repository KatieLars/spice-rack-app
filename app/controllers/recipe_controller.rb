class RecipeController < AppController

  get '/recipes' do #idnex page for logged_in users
    if logged_in? && current_user.recipes.any?
      @recipes = current_user.recipes
      erb :"recipes/index"
    elsif logged_in? && current_user.recipes.none?
      flash.now[:empty_notification] = "Your recipe book is empty" #flash notification not working
      erb :"recipes/index"
    else
      redirect "/"
    end
  end

  get '/recipes/new' do #new spice form
    if logged_in?
      erb :"recipes/new"
    else
      redirect '/login'
    end
  end

  post '/recipes/new' do
    if logged_in?
      delete_blank_values(params[:recipe])
      @recipe = current_user.recipes.build(params[:recipe])
      if @recipe.save
        @recipe.update_spice_user_id
        redirect to "/recipes/#{@recipe.name}"
      else
        flash[:error] = @recipe.errors.full_messages.to_sentence
        redirect to '/recipes/new'
      end
    else
      redirect '/login'
    end
  end

  get '/recipes/:slug' do #show page
    if logged_in?
      if @recipe = current_user.recipes.find_by_slug(params[:slug])
        erb :"recipes/show"
      else
        flash.next[:no_recipe] = "This recipe is not in your book"
        redirect '/recipes'
      end
    else
      redirect '/login'
    end
  end

  get '/recipes/:slug/edit' do
    if logged_in?
      @recipe = current_user.recipes.find_by_slug(params[:slug])
      erb :"recipes/edit"
    else
      redirect '/login'
    end
  end

  patch '/recipes/:slug/edit' do #needs to update spice info
    if logged_in?
      @recipe = current_user.recipes.find_by_slug(params[:slug])
      delete_blank_values(params[:recipe])
      if @recipe.update(params[:recipe])
        @recipe.update_spice_user_id #think about putting this method in Spice model
        redirect to "/recipes/#{@recipe.name}"
      else
        flash[:error] = @recipe.errors.full_messages.to_sentence
        redirect to '/recipes/new'
      end
    else
      redirect '/login'
    end
  end

  delete '/recipes/:slug/delete' do
    if logged_in?
      if recipe = current_user.recipes.find_by_slug(params[:slug])
        flash.next[:deleted_recipe] = "#{recipe.name} deleted!"
        recipe.delete
        redirect "/recipes"
      else
        flash.next[:no_recipe]
        redirect "/recipes"
      end
    else
      redirect '/login'
    end
  end


end
