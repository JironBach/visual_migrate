Rails.application.routes.draw do
  mount VisualMigrate::Engine, at: "/visual_migrate"

  root to: 'index#index'
  match 'index(/:action(/:id))(.:format)', to: "index#:action", via: [:get, :post]
end
