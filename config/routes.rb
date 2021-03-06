require 'sidekiq/web'

Edgar::Application.routes.draw do


  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  get "backdoor/play1"
  get "backdoor/play2"
  get "backdoor/play3"
  get "tags/index"
  

  scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/  do
    authenticated :user do
      root :to => 'home#index'
      get "search/index"
    end
    
    authenticated :user, lambda {|u| u.id == 1} do
      mount Sidekiq::Web, at: "/sidekiq"
    end

    devise_scope :user do
      root :to => "showcase#index", :as => "locale_root", constraints: {subdomain: 'www'}
      # root :to => "devise/registrations#new", :as => "locale_root", constraints: {subdomain: 'soonlaunch'}
      match '/user/confirmation' => 'confirmations#update', :via => :put, :as => :update_user_confirmation
      match '', to: 'sessions#new', constraints: {subdomain: /.+/}
      get "features", to: "showcase#features"
      get "about", to: "showcase#about"
      

    end
    devise_for :users, :controllers => { :registrations => "registrations", :confirmations => "confirmations", :sessions => "sessions"}
    match 'users/bulk_invite/:quantity' => 'users#bulk_invite', :via => :get, :as => :bulk_invite
    resources :users do
      get 'invite', :on => :member
    end

    get "welcome", to: "welcome#index"
    get "home", to: "home#index"
    get "dashboard", to: "dashboard#index"

    resources :structures do
      put 'people/:id/set_main_person', action: :set_main_person, as: :set_main_person
      resources :people
    end
    resources :festivals
    resources :show_buyers
    resources :venues do
      resources :people
      resources :tasks do
        put 'complete', :on => :member
        put 'uncomplete', :on => :member
      end
    end
    resources :people do
      resources :tasks do
        put 'complete', :on => :member
        put 'uncomplete', :on => :member
      end
    end
    resources :tasks do
      put 'complete', :on => :member
      put 'uncomplete', :on => :member
    end
    resources :contacts do
      resources :tasks do
        put 'complete', :on => :member
        put 'uncomplete', :on => :member
      end

      get 'only/:filter', action: :only, on: :collection, as: :only
      get 'add_to_favorites', on: :member
      get 'remove_to_favorites', on: :member
      get 'show_map', on: :collection
    end
    resource :account do
      put 'import_samples', action: :import_samples, as: :import_samples
      
      resources :abilitations
    end
    resources :reportings

    resources :campaigns
    resources :opportunities

    resources :projects
    
    resources :styles, only: [:index]
    resources :networks, only: [:index]
    resources :customs, only: [:index]
    
    resources :jobs, only: [:show]

    resources :imports
    resources :exports, only: [:new]
    
    resources :announcements, only: [:index]
    resources :coupons

  end

# handles /
  root to: redirect("/#{I18n.default_locale}")
  # match '*path', :to => 'errors#routing'
end
#== Route Map
# Generated on 14 Aug 2013 18:50
#
#             search_index GET    /:locale/search/index(.:format)                     search#index {:locale=>/en|fr/}
#              locale_root        /:locale(.:format)                                  devise/registrations#new {:subdomain=>"www", :locale=>/en|fr/}
# update_user_confirmation PUT    /:locale/user/confirmation(.:format)                confirmations#update {:locale=>/en|fr/}
#                                 /:locale(.:format)                                  sessions#new {:subdomain=>/.+/, :locale=>/en|fr/}
#         new_user_session GET    /:locale/users/sign_in(.:format)                    sessions#new {:locale=>/en|fr/}
#             user_session POST   /:locale/users/sign_in(.:format)                    sessions#create {:locale=>/en|fr/}
#     destroy_user_session DELETE /:locale/users/sign_out(.:format)                   sessions#destroy {:locale=>/en|fr/}
#            user_password POST   /:locale/users/password(.:format)                   devise/passwords#create {:locale=>/en|fr/}
#        new_user_password GET    /:locale/users/password/new(.:format)               devise/passwords#new {:locale=>/en|fr/}
#       edit_user_password GET    /:locale/users/password/edit(.:format)              devise/passwords#edit {:locale=>/en|fr/}
#                          PUT    /:locale/users/password(.:format)                   devise/passwords#update {:locale=>/en|fr/}
# cancel_user_registration GET    /:locale/users/cancel(.:format)                     registrations#cancel {:locale=>/en|fr/}
#        user_registration POST   /:locale/users(.:format)                            registrations#create {:locale=>/en|fr/}
#    new_user_registration GET    /:locale/users/sign_up(.:format)                    registrations#new {:locale=>/en|fr/}
#   edit_user_registration GET    /:locale/users/edit(.:format)                       registrations#edit {:locale=>/en|fr/}
#                          PUT    /:locale/users(.:format)                            registrations#update {:locale=>/en|fr/}
#                          DELETE /:locale/users(.:format)                            registrations#destroy {:locale=>/en|fr/}
#        user_confirmation POST   /:locale/users/confirmation(.:format)               confirmations#create {:locale=>/en|fr/}
#    new_user_confirmation GET    /:locale/users/confirmation/new(.:format)           confirmations#new {:locale=>/en|fr/}
#                          GET    /:locale/users/confirmation(.:format)               confirmations#show {:locale=>/en|fr/}
#              bulk_invite GET    /:locale/users/bulk_invite/:quantity(.:format)      users#bulk_invite {:locale=>/en|fr/}
#              invite_user GET    /:locale/users/:id/invite(.:format)                 users#invite {:locale=>/en|fr/}
#                    users GET    /:locale/users(.:format)                            users#index {:locale=>/en|fr/}
#                          POST   /:locale/users(.:format)                            users#create {:locale=>/en|fr/}
#                 new_user GET    /:locale/users/new(.:format)                        users#new {:locale=>/en|fr/}
#                edit_user GET    /:locale/users/:id/edit(.:format)                   users#edit {:locale=>/en|fr/}
#                     user GET    /:locale/users/:id(.:format)                        users#show {:locale=>/en|fr/}
#                          PUT    /:locale/users/:id(.:format)                        users#update {:locale=>/en|fr/}
#                          DELETE /:locale/users/:id(.:format)                        users#destroy {:locale=>/en|fr/}
#             venue_people GET    /:locale/venues/:venue_id/people(.:format)          people#index {:locale=>/en|fr/}
#                          POST   /:locale/venues/:venue_id/people(.:format)          people#create {:locale=>/en|fr/}
#         new_venue_person GET    /:locale/venues/:venue_id/people/new(.:format)      people#new {:locale=>/en|fr/}
#        edit_venue_person GET    /:locale/venues/:venue_id/people/:id/edit(.:format) people#edit {:locale=>/en|fr/}
#             venue_person GET    /:locale/venues/:venue_id/people/:id(.:format)      people#show {:locale=>/en|fr/}
#                          PUT    /:locale/venues/:venue_id/people/:id(.:format)      people#update {:locale=>/en|fr/}
#                          DELETE /:locale/venues/:venue_id/people/:id(.:format)      people#destroy {:locale=>/en|fr/}
#                   venues GET    /:locale/venues(.:format)                           venues#index {:locale=>/en|fr/}
#                          POST   /:locale/venues(.:format)                           venues#create {:locale=>/en|fr/}
#                new_venue GET    /:locale/venues/new(.:format)                       venues#new {:locale=>/en|fr/}
#               edit_venue GET    /:locale/venues/:id/edit(.:format)                  venues#edit {:locale=>/en|fr/}
#                    venue GET    /:locale/venues/:id(.:format)                       venues#show {:locale=>/en|fr/}
#                          PUT    /:locale/venues/:id(.:format)                       venues#update {:locale=>/en|fr/}
#                          DELETE /:locale/venues/:id(.:format)                       venues#destroy {:locale=>/en|fr/}
#                   people GET    /:locale/people(.:format)                           people#index {:locale=>/en|fr/}
#                          POST   /:locale/people(.:format)                           people#create {:locale=>/en|fr/}
#               new_person GET    /:locale/people/new(.:format)                       people#new {:locale=>/en|fr/}
#              edit_person GET    /:locale/people/:id/edit(.:format)                  people#edit {:locale=>/en|fr/}
#                   person GET    /:locale/people/:id(.:format)                       people#show {:locale=>/en|fr/}
#                          PUT    /:locale/people/:id(.:format)                       people#update {:locale=>/en|fr/}
#                          DELETE /:locale/people/:id(.:format)                       people#destroy {:locale=>/en|fr/}
#                     root        /                                                   :controller#:action
#                                 /*path(.:format)                                    errors#routing
