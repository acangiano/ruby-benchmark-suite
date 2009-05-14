ActionController::Routing::Routes.draw do |map|
# default
map.connect '',
  :controller => 'content_nodes',
  :action     => 'show_by_name',
  :name       => 'home'
map.connect '/',
  :controller => 'content_nodes',
  :action     => 'show_by_name',
  :name       => 'home'

# Default administration mapping
map.connect 'admin',
  :controller => 'admin/orders',
  :action     => 'index'

map.connect '/blog',
  :controller => 'content_nodes',
  :action     => 'index'

map.connect '/blog/section/:section_name',
  :controller => 'content_nodes',
  :action     => 'list_by_section'

# Static route blog content through our content_node controller
map.connect '/blog/:name',
  :controller => 'content_nodes',
  :action     => 'show_by_name'


map.connect '/contact',
  :controller => 'questions',
  :action     => 'ask'

map.connect '/store/show_by_tags/*tags',
  :controller => 'store',
  :action     => 'show_by_tags'

# Install the default route as the lowest priority.
map.connect ':controller/:action/:id.:format'
map.connect ':controller/:action/:id'

# For things like /about_us, etc
map.connect ':name',
  :controller => 'content_nodes',
  :action     => 'show_by_name'

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
