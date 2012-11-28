PortalMc437::Application.routes.draw do
  
  get "cart/index"

  resources :items, :cart, :user

  #root :to => "home#index"

  post "/" => "home#login"
  get "/" => "home#login"
  get "/index" => "home#index"
  post "/index" => "home#index"
  get "/cart" => "cart#index"
  get "/card" => "home#card"
  get "/boleto" => "home#boleto"
  get "/payment" => "home#payment"
  get "/customer_support" => "home#customer_support"

  get "/success" => "home#success"

  get "/cartao" => "home#cartao"
  
  post "/cart/add/:id" => "cart#add"
  get "/cart/add/:id" => "cart#add"
  post "/cart/change/:id" => "cart#change"
  get "/cart/change/:id" => "cart#change"
  get "/index/add/:code" => "home#add_item"
  get "/index/sub/:code" => "home#sub_item"




  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
