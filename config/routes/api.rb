Rails.application.routes.draw do
  namespace :api, defaults: { format: "json" } do
    resources :profiles, only: [:show, :index]
    resources :courts, only: [:index, :show]
    get "judges", to: "profiles#judges", as: :judges
    get "prosecutors", to: "profiles#prosecutors", as: :prosecutors
  end

  constraints subdomain: "api" do
    get '/:id/verdict', to: "api/verdicts#show", constraints: { id: /\w{3}-\d{2,3}-.+-\d+/ }
  end
end
