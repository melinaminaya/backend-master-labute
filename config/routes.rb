# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  root to: 'home#index'

  scope :v1 do
    # Routes for Admins with devise
    mount_devise_token_auth_for 'Admin', at: 'auth/admin', controllers: {
      sessions: 'v1/auth/admins/sessions',
      registrations: 'v1/auth/admins/registrations',
      passwords: 'v1/auth/admins/passwords'
    }
    as :admin do
    end

    mount_devise_token_auth_for 'Worker', at: 'auth/worker', controllers: {
      sessions: 'v1/auth/workers/sessions',
      token_validations: 'v1/auth/workers/token_validations',
      registrations: 'v1/auth/workers/registrations',
      passwords: 'v1/auth/workers/passwords'
    }
    as :worker do
    end

    mount_devise_token_auth_for 'Client', at: 'auth/client', controllers: {
      sessions: 'v1/auth/clients/sessions',
      token_validations: 'v1/auth/clients/token_validations',
      registrations: 'v1/auth/clients/registrations',
      passwords: 'v1/auth/clients/passwords'
    }
    as :client do
      # Define routes for Client within this block.
    end
  end

  namespace :v1 do
    ## Do not remove next line - Health Check needed
    get 'status', to: 'base#status'

    get 'proposals/services', to: 'proposals#services'
    get 'workers/categories', to: 'workers#categories'

    resources :admins, except: %i[new edit]
    resources :categories, except: %i[new]
    resources :sub_categories, except: %i[new]
    resources :workers, except: %i[new]
    resources :clients, except: %i[new]
    resources :services, except: %i[new edit]
    resources :proposals, except: %i[new edit]
    resources :transactions, except: %i[new edit]
    resources :problems, except: %i[new edit]
    resources :cancellations, except: %i[new edit]
    resources :evaluations, except: %i[new edit]
    resources :cupons, except: %i[new edit]
    resources :cupon_usages, except: %i[new edit]
    resources :s3_upload_signers, only: [:create], path: 's3-sign'

    post 's3-sign/unauthenticated', to: 's3_upload_signers#create_for_unauthenticated'
    post 's3-sign/service', to: 's3_upload_signers#create_for_service'

    post 'workers/create-register', to: 'workers#create_register'
    post 'workers/update-register', to: 'workers#update_register'
    post 'workers/validate', to: 'workers#validate_confirmation'
    post 'workers/upload-file', to: 'workers#upload_file'
    post 'workers/upload-image', to: 'workers#upload_image'
    post 'workers/resend-code', to: 'workers#resend_code'
    post 'workers/reject', to: 'workers#reject'
    post 'workers/approve', to: 'workers#approve'

    post 'clients/create-register', to: 'clients#create_register'
    post 'clients/update-register', to: 'clients#update_register'
    post 'clients/validate', to: 'clients#validate_confirmation'
    post 'clients/upload-file', to: 'clients#upload_file'
    post 'clients/upload-image', to: 'clients#upload_image'
    post 'clients/resend-code', to: 'clients#resend_code'
    post 'clients/reject', to: 'clients#reject'
    post 'clients/approve', to: 'clients#approve'

    post 'services/approve', to: 'services#approve'
    post 'services/reject', to: 'services#reject'
    post 'services/finish', to: 'services#finish'
    post 'services/sign', to: 'services#sign'
    post 'services/worker-requests', to: 'services#worker_requested_services'
    post 'services/worker', to: 'services#worker_services'
    post 'services/charge', to: 'services#charge'
    post 'services/refuse_charge', to: 'services#refuse_charge'
    post 'services/chat_notification', to: 'services#chat_notification'

    post 'proposals/accept', to: 'proposals#accept'
    post 'proposals/reject', to: 'proposals#reject'
    post 'proposals/approve', to: 'proposals#approve'

    post 'transactions/authenticate', to: 'transactions#authenticate'
    post 'transactions/notification', to: 'transactions#notification'
    post 'transactions/charge', to: 'transactions#charge'

    post 'cupons/exists', to: 'cupons#exists'

    post 'notifications/send', to: 'notifications#notify'
  end

  resources :docs, only: [:index]

  if ENV['SIDEKIQ_USER'].present? && ENV['SIDEKIQ_PASSWORD'].present?
    mount Sidekiq::Web => '/sidekiq'
  end

  # Errors
  match '*unmatched_route', to: 'application#raise_not_found!', via: %i[get post]
end
