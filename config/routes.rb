Spree::Core::Engine.routes.draw do
  namespace :hub do
    post '*path', to: 'webhook#consume', as: 'webhook'
  end
end
