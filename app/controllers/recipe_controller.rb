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
        recipe.spices << old_spice  unless repeat_spices_or_recipes(current_user.spices, old_spice)
      end
      recipe.save
      redirect "/recipes/#{recipe.slug}"
    elsif current_user && recipe.save && !spice.save && !!params[:recipe][:spice_ids]
      #current_user, valid recipe, spice NOT valid, and spice_ids

      recipe.update(:user_id => session[:user_id])
      params[:recipe][:spice_ids].each do |spice_id|
        old_spice = Spice.find_by_id(spice_id)
        recipe.spices << old_spice  unless repeat_spices_or_recipes(current_user.spices, old_spice)
        recipe.save
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
    if current_user.id == @recipe.user_id
      erb :"recipes/show"
    else
      flash.next[:no_recipe] = "This recipe is not in your book"
      redirect '/recipes'
    end
  end

  get '/recipes/:slug/edit' do
    @user = current_user
    if current_user
      @recipe = Recipe.find_by_slug(params[:slug])
      erb :"recipes/edit"
    else
      redirect '/login'
    end
  end

  patch '/recipes/:slug/edit' do #needs to update spice info
    recipe = Recipe.find_by_slug(params[:slug])
    customer_recipe = Recipe.find_by(:user_id => session[:user_id], :name => recipe.name)
    if current_user && customer_recipe && !!params[:spice].has_value?("") && !params[:recipe][:spice_ids]
      #valid user, valid spice, no recipe params, no recipe_ids
      customer_recipe.update(name: params[:recipe][:name]) unless params[:recipe][:name].empty?
      customer_recipe.update(url: params[:recipe][:url]) unless params[:recipe][:url].empty?

      customer_recipe.spices.clear
      flash.next[:update_recipe] = "#{customer_recipe.name} updated!"
      redirect "/recipes/#{customer_recipe.slug}"
    elsif current_user && customer_recipe && !params[:spice].has_value?("") && !params[:recipe][:spice_ids]
      #valid user, valid spice, has new recipe params, no previous recipes checked
      customer_recipe.update(name: params[:recipe][:name]) unless params[:recipe][:name].empty?
      customer_recipe.update(url: params[:recipe][:url]) unless params[:recipe][:url].empty?
      customer_recipe.spices.clear
      spice = Spice.create(params[:spice])
      if !repeat_spices_or_recipes(current_user.spices, spice)
        #if the recipe is not a repeat
        spice.update(:user_id => session[:user_id])
        customer_recipe.spices << spice #unless repeat_spices_or_recipes(current_user.spices, spice)
        customer_recipe.save
        #binding.pry
      else

        flash.next[:repeat_recipe] = "#{recipe.name.capitalize} is already in your recipe book"
        redirect "/recipes/#{customer_recipe.slug}"
      end
      flash.next[:update_recipe] = "#{customer_recipe.name} updated!"
      redirect "/recipes/#{customer_recipe.slug}"
    elsif current_user && customer_recipe && !params[:spice].has_value?("") && !!params[:recipe][:spice_ids]
      #valid user, valid spice, has recipe params, recipe_ids
      customer_recipe.update(name: params[:recipe][:name]) unless params[:recipe][:name].empty?
      customer_recipe.update(url: params[:recipe][:url]) unless params[:recipe][:url].empty?
      customer_recipe.spices.clear
      spice = Spice.create(params[:spice])

      if !repeat_spices_or_recipes(current_user.spices, spice)
        #saves valid recipe and checks for repeats
        spice.update(:user_id => session[:user_id])
        customer_recipe.spices << spice #unless repeat_spices_or_recipes(current_user.spices, spice)

        customer_recipe.save
      else
        flash.next[:repeat_spice] = "#{spice.name.capitalize} is already in your recipe book"
        redirect "/recipes/#{customer_recipe.slug}"
      end
      params[:recipe][:spice_ids].each {|spice_id| customer_recipe.spices << Spice.find_by_id(spice_id)}
      customer_recipe.save
      flash.next[:update_recipe] = "#{customer_recipe.name} updated!"
      redirect "/recipes/#{customer_recipe.slug}"
    elsif current_user && customer_recipe && !!params[:spice].has_value?("") && !!params[:recipe][:spice_ids]
      #valid customer, valid spice, no new recipes created, and new recipe_ids
      customer_recipe.update(name: params[:recipe][:name]) unless params[:recipe][:name].empty?
      customer_recipe.update(url: params[:recipe][:url]) unless params[:recipe][:url].empty?
      customer_recipe.spices.clear

      params[:recipe][:spice_ids].each {|spice_id| customer_recipe.spices << Spice.find_by_id(spice_id)}
      customer_recipe.save
      flash.next[:update_recipe] = "#{customer_recipe.name} updated!"
      redirect "/recipes/#{customer_recipe.slug}"
    else
      redirect '/login'
    end
  end

  delete '/recipes/:slug/delete' do
    recipe = Recipe.find_by_slug(params[:slug])
    if current_user.id == recipe.user_id
      flash.next[:deleted_recipe] = "#{recipe.name} deleted!"
      recipe.delete
      redirect "/recipes"
    else
      redirect '/login'
    end
  end


end
