VisualMigrate::Engine.routes.draw do
  root :to => "index#index"
  
  #match '/:controller(/:action(/:id))', :controller => /visual_migrate\/[^\/]+/
  match 'index(/:action(/:id))', :controller => :index
end
