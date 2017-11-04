# -*- encoding : utf-8 -*-
Rails.application.routes.draw do

  namespace :interface do
    resources :areas do
      collection do
        get :area_data
      end
    end
  end

end
