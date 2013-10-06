VisualMigrate::Engine.routes.draw do
  root :to => 'index#index' #Why needs?
  #match ':controller(/:action(/:id))(.:format)'
  resource 'index'
end
