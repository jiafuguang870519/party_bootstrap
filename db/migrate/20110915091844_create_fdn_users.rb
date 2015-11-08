class CreateFdnUsers < ActiveRecord::Migration
  def change
    create_table :fdn_users do |t|
      t.string    :username,            :null => false                # optional, you can use email instead, or both      
      t.string    :encrypted_password,  :null => false                # optional, see below
      t.string    :password_salt,       :null => false                # optional, but highly recommended
      t.string    :persistence_token,   :null => false                # required
      t.string    :single_access_token, :null => false                # optional, see Authlogic::Session::Params
      t.string    :perishable_token,    :null => false                # optional, see Authlogic::Session::Perishability
      
      #我们需要用的列
      t.string    :resource_type
      t.integer   :resource_id
      t.string    :status
      t.string    :ghost  ,default: 'N'
      
      
      # Magic columns, just like ActiveRecord's created_at and updated_at. These are automatically maintained by Authlogic if they are present.
      t.integer   :login_count,         :null => false, :default => 0 # optional, see Authlogic::Session::MagicColumns
      t.integer   :failed_login_count,  :null => false, :default => 0 # optional, see Authlogic::Session::MagicColumns
      t.datetime  :last_request_at                                    # optional, see Authlogic::Session::MagicColumns
      t.datetime  :current_login_at                                   # optional, see Authlogic::Session::MagicColumns
      t.datetime  :last_login_at                                      # optional, see Authlogic::Session::MagicColumns
      t.string    :current_login_ip                                   # optional, see Authlogic::Session::MagicColumns
      t.string    :last_login_ip                                      # optional, see Authlogic::Session::MagicColumns

      
      t.timestamps
      t.tracer
    end

    add_index :fdn_users, :username
    add_index :fdn_users, [:resource_type, :resource_id], :name=>'fdn_users_ind1'
    add_index :fdn_users, :status
    add_index :fdn_users, :persistence_token
  end
end
