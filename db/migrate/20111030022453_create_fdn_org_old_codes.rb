class CreateFdnOrgOldCodes < ActiveRecord::Migration
  def change
    create_table :old_codes_organizations, :id=>false do |t|
      t.integer :old_code_id
      t.integer :organization_id

    end
  end
end
