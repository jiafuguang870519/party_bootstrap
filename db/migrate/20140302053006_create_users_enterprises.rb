class CreateUsersEnterprises < ActiveRecord::Migration
  def change
    create_table :users_enterprises, :id=>false do |t|
      t.references :user
      t.references :enterprise
    end

    add_index :users_enterprises, [:user_id, :enterprise_id], :unique => true, :name => 'users_enterprises_ind1'
  end
end

