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
  spice = Spice.new(params[:spice])
  recipe = Recipe.new(params[:recipe])
  if repeat_spices_or_recipes(current_user.spices, spice)
    flash.next[:repeat_spice] = "#{spice.name.capitalize} is already in your rack"
    redirect "/spices/#{spice.slug}"
    #if new spice already exists in user's rack
  elsif repeat_spices_or_recipes(current_user.recipes, recipe)
    flash.next[:repeat_recipe] = "#{recipe.name.capitalize} is already in your recipe book"
    redirect "/recipes/#{recipe.slug}"
    #if recipe already exists for user (recipe names must be unique)
  elsif current_user && spice.save && recipe.save #&& !params[:spice][:recipe_ids].empty? #validations kick in--none of the names can be blank
    #if user logged in, spice is valid, and recipe is valid and there are recipe_ids
    spice.update(:user_id => session[:user_id])
    recipe.update(:user_id => session[:user_id])
    spice.recipes << recipe
    spice.save
    redirect "/spices/#{spice.slug}"
  elsif current_user && spice.save && !recipe.save #&& params[:spice][:recipe_ids].empty?
    flash.next[:blank_warning] = "Recipe name cannot be blank"
    redirect '/spices/new'
  elsif current_user && !spice.save
    flash.next[:blank_warning] = "Spice name cannot be blank"
    redirect '/spices/new'
  else
    redirect '/login'
  end
end

get '/spices/:slug' do #show
  slug_spice = Spice.find_by_slug(params[:slug])
  customer_spice = Spice.find_by(:user_id => session[:user_id], :name => slug_spice.name)
  @user = current_user
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
  #info to update:
    #flavor, recipes, name
  #creates a new recipe if need be
  #if the user leaves anything blank, does not update or create new object
  spice = Spice.find_by_slug(params[:slug])
  customer_spice = Spice.find_by(:user_id => session[:user_id], :name => spice.name)
  if current_user
    customer_spice.update
  end
end

#helper methods
def repeat_spices_or_recipes(current_user_array, comp_obj)
  #detects blank or repeat spices or recipes
  current_user_array.detect {|obj| comp_obj.name.upcase == obj.name.upcase}
end

end
