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

  post '/recipes/new' do

    recipe = Recipe.new(params[:recipe])
    spice = Spice.new(params[:spice])
    if current_user && !recipe.save
      #valid user, blank recipe name
      flash.next[:blank_warning] = "Recipe name cannot be blank"
      redirect '/recipes/new'
    elsif repeat_spices_or_recipes(current_user.recipes, recipe)
      flash.next[:repeat_recipe] = "#{recipe.name.capitalize} is already in your recipe book"
      redirect "/recipes/#{recipe.slug}"
      #if new recipe already exists in user's book
    elsif repeat_spices_or_recipes(current_user.spices, spice)
      flash.next[:repeat_spice] = "#{spice.name.capitalize} is already in your rack"
      redirect "/spices/#{spice.slug}"
      #if spice already exists for user
    elsif current_user && recipe.save && spice.save && params[:recipe][:spice_ids]
      #current_user, valid recipe, valid spice, spice_ids
      spice.update(:user_id => session[:user_id])
      recipe.update(:user_id => session[:user_id])
      recipe.spices << spice
      params[:recipe][:spice_ids].each do |spice_id|
        old_spice = Spice.find_by_id(spice_id)
        recipe.spices << old_spice
      end
      recipe.save
      redirect "/recipes/#{recipe.slug}"
    elsif current_user && recipe.save && !spice.save && !!params[:recipe][:spice_ids]
      #current_user, valid recipe, spice NOT valid, and recipe_ids
      params[:recipe][:spice_ids].each do |spice_id|
        old_spice = Spice.find_by_id(spice_id)
        recipe.spices << old_spice
        spice.save
      end
      redirect "/recipes/#{recipe.slug}"
    elsif current_user && recipe.save && spice.save && !params[:recipe][:spice_ids]
      #current_user, valid spice, valid recipe, and no spice_ids
      recipe.update(:user_id => session[:user_id])
      spice.update(:user_id => session[:user_id])
      recipe.spices << spice
      recipe.save
      redirect "/recipes/#{recipe.slug}"
    elsif current_user && recipe.save && !spice.save && !params[:recipe][:spice_ids]
      #valid user, valid recipe, not valid spice, no spice_ids
      recipe.update(:user_id => session[:user_id])
      redirect "/recipes/#{recipe.slug}"
    else
      redirect '/login'
    end
  end

  get '/recipes/:slug' do
    @recipe = Recipe.find_by_slug(params[:slug])
    if currrent_user.id == @recipe.user_id
      erb :"recipes/show"
    else
      flash.next[:no_recipe] = "This recipe is not in your book"
      redirect '/recipes'
    end
  end


end
