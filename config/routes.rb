Rails.application.routes.draw do
  root to: "home#index"

  namespace :api do
    namespace :v1 do
      resources :mods, param: :id, only: [:index, :show], constraints: {
        id: Patterns.json_or_slug(Patterns::ROUTE_PATTERN) } do
        resources :versions, param: :number, only: [:index, :show], constraints: {
          number: Patterns.json_or_slug(FoobarMod::Version::VERSION_PATTERN)
        }
      end
    end
  end

  resources :mods,
    only: [:index, :show],
    param: :id,
    constraints: { id: Patterns::ROUTE_PATTERN, format: /html/ } do
    resources :versions, only: [:index, :show]
  end

  resources :passwords, controller: "clearance/passwords", only: [:create, :new]
  resource :session, controller: "clearance/sessions", only: [:create]

  resources :users, controller: "clearance/users", only: [:create] do
    resource :password,
      controller: "clearance/passwords",
      only: [:create, :edit, :update]
  end

  get "/sign_in" => "clearance/sessions#new", as: "sign_in"
  delete "/sign_out" => "clearance/sessions#destroy", as: "sign_out"
  get "/sign_up" => "clearance/users#new", as: "sign_up"
end
