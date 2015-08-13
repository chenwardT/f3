Rails.application.routes.draw do
  devise_for :users
  get 'static_pages/index'

  resources :users

  # TODO: Consider routing styles for content
  #   with slugs...
  #   show a-hot-topic, posted in some-forum:
  #   /some-forum-slug/a-hot-topic-slug/
  #   /topic-slug/
  #   /topic-slug?page=page-num#post-num
  #
  #   without slugs...
  #   show forum ID = 12, with no indication of nesting:
  #   /forum/12

  resources :forums
  resources :topics
  resources :posts

  post 'hard_delete_post' => 'posts#hard_delete'
  post 'soft_delete_post' => 'posts#soft_delete'
  post 'undelete_post' => 'posts#undelete'
  post 'approve_post' => 'posts#approve'
  post 'unapprove_post' => 'posts#unapprove'
  post 'merge_post' => 'posts#merge'
  post 'move_post' => 'posts#move'
  post 'copy_post' => 'posts#copy'

  resources :groups

  root 'forums#index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
