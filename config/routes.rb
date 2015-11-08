Rails.application.routes.draw do
  namespace :fdn do
    resources :party_orgs do

      collection do
        post 'import'
      end
    end
  end
  namespace :aae do
    resources :financial_statements do
        collection do
          get 'ajax_refresh','year_analysis','year_index','month_analysis', 'short_term_debt_paying','long_term_debt_paying','assess_of_economic'
        end
    end
  end
  get 'main/index'

  get 'login/index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  #root 'login#index'
  root 'fdn/user_sessions#new'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  namespace :fdn do
    #用户管理
    resources :users do
      collection do
        get 'detail_refresh', 'stop'
      end
    end
    #功能菜单
    resources :menus do
      collection do
        get 'tree', 'detail_refresh'
      end
    end
    #权限管理
    resources :roles do
      member do
        get 'user', 'right', 'refresh', 'destroy_record'
      end
      collection do
        get 'autocomplete_organization_id', 'treeload', 'kb_tree', 'nb_tree', 'ys_tree', 'org_tree'
        get 'detail_refresh'
      end
    end
    #系统公告
    resources :announcements do
      collection do
        get 'add_file', 'del_file'
      end
    end
    #通知公告
    resources :legends do
      collection do
        get 'add_file', 'add_file_of', 'del_file', 'del_file_of'
        get 'gov_widget', 'ent_widget', 'district_widget', 'important', 'gov_content'
      end
      member do
        get 'show_page'
      end
    end
    #组织管理
    resources :organizations do
      collection do
        get 'rjs_all_of', 'tree_index' , 'ent_index'
      end
    end
    #用户sessions
    resources :user_sessions do
      collection do
        get 'js_render_captcha'
      end
      member do
        get 'quit'
      end
    end
    #系统日志
    resources :loggers do
      collection do
        get 'show_info'
      end
    end
    #组织架构
    resources :org_hierarchies

  end

  namespace :oa do
    resources :sent_documents do
      collection do
        get 'add_file', 'del_file'
      end
    end
  end

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
