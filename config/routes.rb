Pair::Application.routes.draw do
  root :to => 'welcome#index'
  
  resources :questions, as: :item_groups, controller: :item_groups

  # Keep this last
  scope ':group_key' do
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
