Spree::Core::Engine.add_routes do
  namespace :hub do
    post '*path', to: 'webhook#consume', as: 'webhook'
  end
end