require 'resque/server'

Pair::Application.routes.draw do
  resources :questions, as: :item_groups, controller: :item_groups do
    collection do
      get 'mine'
    end
  end

  match '/login' => 'user#login'
  match '/logout' => 'user#logout'

  root :to => 'welcome#index'

  mount Resque::Server.new, :at => "/resque"

  # Keep this last
  scope ':group_key' do
    get '/' => 'items#index'

    resources :items

    scope 'vote', controller: :vote do
      get '/', as: 'new_vote', action: :new
      get ':item1::item2', :as => 'votes', :action => :show
      post ':item1::item2(/pick)/:choose', :as => 'vote_on_item', :action => :choose
      get  ':item1::item2(/pick)/:choose', :action => :show
    end
  end

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'

end
