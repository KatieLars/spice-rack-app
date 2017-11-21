
class SpiceController < AppController

  get '/spices' do #index
    if logged_in?
      if current_user.spices.any?
        erb :"spices/index"
      else
        flash.now[:empty_notification] = "Your spice rack is empty"
        erb :"/"
      end
    else
      redirect "/login"
    end
  end

  get '/spices/flavors' do #index by flavor
    if logged_in?
      erb :"spices/flavors"
    else
      redirect '/login'
    end
  end

get '/spices/new' do #new spice form
  if logged_in?
    erb :"spices/new"
  else
    redirect '/login'
  end
end

post '/spices/new' do #should create a new spice and recipe
  if logged_in?
    delete_blank_values(params[:spice])
    @spice = current_user.spices.build(params[:spice])
    if @spice.save
      @spice.update_recipe_user_id
      redirect to "/spices/#{@spice.name}"
    else
      flash[:error] = @spice.errors.full_messages.to_sentence
      redirect to '/spices/new'
    end
  else
    redirect '/login'
  end
end

get '/spices/:slug' do #show
  if logged_in?
    if @spice = current_user.spices.find_by_slug(params[:slug])
      erb :"spices/show"
    else
      flash.next[:no_spice] = "This recipe is not in your book"
      redirect '/spices'
    end
  else
    redirect '/login'
  end
end

get '/spices/:slug/edit' do #edit form
  if logged_in?
    @spice = current_user.spices.find_by_slug(params[:slug])
    erb :"spices/edit"
  else
    redirect '/login'
  end
end

patch '/spices/:slug/edit' do #needs to update spice info
  if logged_in?
    @spice = current_user.spices.find_by_slug(params[:slug])
    delete_blank_values(params[:spice])
    if @spice.update(params[:spice])
      @spice.update_recipe_user_id
      redirect to "/spices/#{@spice.name}"
    else
      flash[:error] = @spice.errors.full_messages.to_sentence
      redirect to '/spices/new'
    end
  else
    redirect '/login'
  end
end

delete '/spices/:slug/delete' do
  if logged_in?
    if spice = current_user.spices.find_by_slug(params[:slug])
      flash.next[:deleted_spice] = "#{spice.name} deleted!"
      spice.delete
      redirect "/spices"
    else
      flash.next[:no_spice]
      redirect "/spices"
    end
  else
    redirect '/login'
  end
end



end
