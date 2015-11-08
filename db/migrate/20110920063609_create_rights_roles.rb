class CreateRightsRoles < ActiveRecord::Migration
  def change
    create_table :rights_roles, :id=>false do |t|
      t.references :right   
      t.references :role           
    end

    add_index :rights_roles, [:right_id, :role_id], :unique => true, :name=>'rights_roles_ind1'
  end
end
