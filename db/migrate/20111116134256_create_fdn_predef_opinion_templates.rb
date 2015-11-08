class CreateFdnPredefOpinionTemplates < ActiveRecord::Migration
  def change
    create_table :fdn_predef_opinion_templates do |t|
      t.string :type_code
      t.string :content

      t.timestamps
    end

    add_index :fdn_predef_opinion_templates, :type_code
  end
end
