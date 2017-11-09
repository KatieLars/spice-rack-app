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
      @flavors = current_user.flavors.uniq
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
  spice = Spice.new(params[:spice])
  recipe = Recipe.new(params[:recipe])
  if current_user && !spice.save
    flash.next[:blank_warning] = "Spice name cannot be blank"
    redirect '/spices/new'
  elsif repeat_spices_or_recipes(current_user.spices, spice)
    flash.next[:repeat_spice] = "#{spice.name.capitalize} is already in your rack"
    redirect "/spices/#{spice.slug}"
    #if new spice already exists in user's rack
  elsif repeat_spices_or_recipes(current_user.recipes, recipe)
    flash.next[:repeat_recipe] = "#{recipe.name.capitalize} is already in your recipe book"
    redirect "/recipes/#{recipe.slug}"
    #if recipe already exists for user (recipe names must be unique)
  elsif current_user && spice.save && recipe.save && params[:spice][:recipe_ids]
    #current_user, valid spice, valid recipe, recipe_ids
    spice.update(:user_id => session[:user_id])
    recipe.update(:user_id => session[:user_id])
    spice.recipes << recipe
    params[:spice][:recipe_ids].each do |recipe_id|
      old_recipe = Recipe.find_by_id(recipe_id)
      old_recipe.update(:user_id => session[:user_id])
      spice.recipes << old_recipe unless repeat_spices_or_recipes(current_user.recipes, old_recipe)
    end #updates unless old recipe is a repeat recipe
    spice.save
    redirect "/spices/#{spice.slug}"
  elsif current_user && spice.save && !recipe.save && !!params[:spice][:recipe_ids]
    #current_user, valid spice, recipe NOT valid, and recipe_ids
    params[:spice][:recipe_ids].each do |recipe_id|
      old_recipe = Recipe.find_by_id(recipe_id)
      #old_recipe.update(:user_id => session[:user_id])
      spice.update(:user_id => session[:user_id])
      spice.recipes << old_recipe unless repeat_spices_or_recipes(current_user.recipes, old_recipe)
      spice.save
    end
    redirect "/spices/#{spice.slug}"
  elsif current_user && spice.save && recipe.save && !params[:spice][:recipe_ids]
    #current_user, valid spice, valid recipe, and no recipe_ids
    spice.update(:user_id => session[:user_id])
    recipe.update(:user_id => session[:user_id])
    spice.recipes << recipe
    spice.save
    redirect "/spices/#{spice.slug}"
  elsif current_user && spice.save && !recipe.save && !params[:spice][:recipe_ids]
    spice.update(:user_id => session[:user_id])
    redirect "/spices/#{spice.slug}"
  else
    redirect '/login'
  end
end

get '/spices/:slug' do #show
  slug_spice = Spice.find_by_slug(params[:slug])
  customer_spice = Spice.find_by(:user_id => session[:user_id], :name => slug_spice.name)
  @user = current_user
  if current_user && customer_spice
    @spice = customer_spice
    erb :"spices/show"
  elsif current_user && !customer_spice
    #if customer logged in, but the slug spice is not in his/her rack
    flash.now[:spice_warning] = "This spice is not in your rack."
    erb :"spices/new"
  else #if user not logged in
    redirect '/login'
  end
end

get '/spices/:slug/edit' do
  @user = current_user
  if current_user
    @spice = Spice.find_by_slug(params[:slug])
    erb :"spices/edit"
  else
    redirect '/login'
  end
end

patch '/spices/:slug/edit' do #needs to update spice info
  spice = Spice.find_by_slug(params[:slug])
  customer_spice = Spice.find_by(:user_id => session[:user_id], :name => spice.name)
  if current_user && customer_spice && !!params[:recipe].has_value?("") && !params[:spice][:recipe_ids]
    #valid user, valid spice, no recipe params, no recipe_ids
    customer_spice.update(name: params[:spice][:name]) unless params[:spice][:name].empty?
    customer_spice.update(flavor_id: params[:spice][:flavor_id])

    customer_spice.recipes.clear
    flash.next[:update_spice] = "#{customer_spice.name} updated!"
    redirect "/spices/#{customer_spice.slug}"
  elsif current_user && customer_spice && !params[:recipe].has_value?("") && !params[:spice][:recipe_ids]
    #valid user, valid spice, has new recipe params, no previous recipes checked
    customer_spice.update(name: params[:spice][:name]) unless params[:spice][:name].empty?
    customer_spice.update(flavor_id: params[:spice][:flavor_id])
    customer_spice.recipes.clear
    recipe = Recipe.create(params[:recipe])
    if !repeat_spices_or_recipes(current_user.recipes, recipe)
      #if the recipe is not a repeat
      recipe.update(:user_id => session[:user_id])
      customer_spice.recipes << recipe
      customer_spice.save
    else
      flash.next[:repeat_recipe] = "#{recipe.name.capitalize} is already in your recipe book"
      redirect "/spices/#{customer_spice.slug}"
    end
    flash.next[:update_spice] = "#{customer_spice.name} updated!"
    redirect "/spices/#{customer_spice.slug}"
  elsif current_user && customer_spice && !params[:recipe].has_value?("") && !!params[:spice][:recipe_ids]
    #valid user, valid spice, has recipe params, recipe_ids
    customer_spice.update(name: params[:spice][:name]) unless params[:spice][:name].empty?
    customer_spice.update(flavor_id: params[:spice][:flavor_id])
    customer_spice.recipes.clear
    recipe = Recipe.create(params[:recipe])
    if !repeat_spices_or_recipes(current_user.recipes, recipe)
      #saves valid recipe and checks for repeats
      recipe.update(:user_id => session[:user_id])
      customer_spice.recipes << recipe
      customer_spice.save
    else
      flash.next[:repeat_recipe] = "#{recipe.name.capitalize} is already in your recipe book"
      redirect "/spices/#{customer_spice.slug}"
    end
    params[:spice][:recipe_ids].each {|recipe_id| customer_spice.recipes << Recipe.find_by_id(recipe_id)}
    customer_spice.save
    flash.next[:update_spice] = "#{customer_spice.name} updated!"
    redirect "/spices/#{customer_spice.slug}"
  elsif current_user && customer_spice && !!params[:recipe].has_value?("") && !!params[:spice][:recipe_ids]
    #valid customer, valid spice, no new recipes created, and new recipe_ids
    customer_spice.update(name: params[:spice][:name]) unless params[:spice][:name].empty?
    customer_spice.update(flavor_id: params[:spice][:flavor_id])
    customer_spice.recipes.clear

    params[:spice][:recipe_ids].each {|recipe_id| customer_spice.recipes << Recipe.find_by_id(recipe_id)}
    customer_spice.save
    flash.next[:update_spice] = "#{customer_spice.name} updated!"
    redirect "/spices/#{customer_spice.slug}"
  else
    redirect '/login'
  end
end

delete '/spices/:slug/delete' do
  spice = Spice.find_by_slug(params[:slug])
  if current_user.id == spice.user_id
    flash.next[:deleted_spice] = "#{user_spice.name} deleted!"
    spice.delete
    redirect "/spices"
  else
    redirect '/login'
  end
end
#helper methods
def repeat_spices_or_recipes(current_user_array, comp_obj)
  #detects blank or repeat spices or recipes, returns non-repeat obj
  current_user_array.detect {|obj| comp_obj.name.upcase == obj.name.upcase}
  #iterates over an array of spice/recipe objects associated with user, and
  #checks them against comp_obj to determine of the newly created comp_obj is a repeat
end

def blank_recipe_spice_params(params_hash)
  if !!params_hash.values
    #if there are values in the recipe hash
    recipe = Recipe.new(params_hash)
  end
  recipe
end


end
