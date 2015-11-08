# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151108032550) do

  create_table "fdn_dashboards", force: :cascade do |t|
    t.integer  "user_id",         limit: 11
    t.integer  "organization_id", limit: 11
    t.string   "name",            limit: 255
    t.string   "code",            limit: 255
    t.integer  "active",          limit: 11
    t.text     "layout"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by",      limit: 11
    t.integer  "updated_by",      limit: 11
  end

  add_index "fdn_dashboards", ["organization_id", "active"], name: "index_fdn_dashboards_on_organization_id_and_active", using: :btree
  add_index "fdn_dashboards", ["user_id", "active"], name: "index_fdn_dashboards_on_user_id_and_active", using: :btree

  create_table "fdn_dept_histories", force: :cascade do |t|
    t.integer  "dept_id",    limit: 11
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "seq",        limit: 11
    t.integer  "internal",   limit: 11
    t.string   "type_code",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fdn_depts", force: :cascade do |t|
    t.integer  "seq",        limit: 11
    t.integer  "internal",   limit: 11
    t.datetime "start_time"
    t.string   "type_code",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by", limit: 11
    t.integer  "updated_by", limit: 11
  end

  add_index "fdn_depts", ["internal"], name: "index_fdn_depts_on_internal", using: :btree

  create_table "fdn_ent_ind_histories", force: :cascade do |t|
    t.integer  "ent_id",      limit: 11
    t.integer  "industry_id", limit: 11
    t.integer  "seq",         limit: 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fdn_ent_individual_histories", force: :cascade do |t|
    t.string   "individual_name", limit: 255
    t.string   "actual_investor", limit: 255
    t.integer  "ent_id",          limit: 11
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "last_id",         limit: 11
  end

  create_table "fdn_ent_individuals", force: :cascade do |t|
    t.string   "individual_name", limit: 255
    t.string   "actual_investor", limit: 255
    t.integer  "ent_id",          limit: 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fdn_ent_investor_histories", force: :cascade do |t|
    t.integer  "ent_id",                       limit: 11
    t.string   "investor_type_code",           limit: 255
    t.integer  "org_id",                       limit: 11
    t.string   "investor_name",                limit: 255
    t.string   "region_code",                  limit: 255
    t.string   "org_type_code",                limit: 255
    t.string   "industry_code",                limit: 255
    t.decimal  "amount",                                   precision: 20, scale: 2
    t.decimal  "percentage",                               precision: 20, scale: 2
    t.integer  "lock_version",                 limit: 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by",                   limit: 11
    t.integer  "updated_by",                   limit: 11
    t.decimal  "actual_amt",                               precision: 10, scale: 2
    t.integer  "last_id",                      limit: 11
    t.decimal  "actual_amt_foreign",                       precision: 10, scale: 2
    t.decimal  "capital_contribution",                     precision: 10, scale: 2
    t.decimal  "capital_contribution_foreign",             precision: 10, scale: 2
    t.decimal  "foreign_currency",                         precision: 10, scale: 2
  end

  create_table "fdn_ent_investors", force: :cascade do |t|
    t.integer  "ent_id",                       limit: 11
    t.string   "investor_type_code",           limit: 255
    t.integer  "org_id",                       limit: 11
    t.string   "investor_name",                limit: 255
    t.string   "region_code",                  limit: 255
    t.string   "org_type_code",                limit: 255
    t.string   "industry_code",                limit: 255
    t.decimal  "amount",                                   precision: 20, scale: 2
    t.decimal  "percentage",                               precision: 20, scale: 2
    t.integer  "lock_version",                 limit: 11
    t.decimal  "actual_amt",                               precision: 10, scale: 2
    t.integer  "last_id",                      limit: 11
    t.decimal  "actual_amt_foreign",                       precision: 10, scale: 2
    t.decimal  "capital_contribution",                     precision: 10, scale: 2
    t.decimal  "capital_contribution_foreign",             precision: 10, scale: 2
    t.decimal  "foreign_currency",                         precision: 10, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by",                   limit: 11
    t.integer  "updated_by",                   limit: 11
  end

  add_index "fdn_ent_investors", ["ent_id"], name: "index_fdn_ent_investors_on_ent_id", using: :btree
  add_index "fdn_ent_investors", ["org_id"], name: "index_fdn_ent_investors_on_org_id", using: :btree

  create_table "fdn_ent_result_histories", force: :cascade do |t|
    t.integer  "ent_id",            limit: 11
    t.integer  "row_template_id",   limit: 11
    t.decimal  "value",                        precision: 20, scale: 2
    t.integer  "lock_version",      limit: 11
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.integer  "created_by",        limit: 11
    t.integer  "updated_by",        limit: 11
    t.decimal  "exchange_rate",                precision: 20, scale: 2
    t.decimal  "foreign_currency",             precision: 20, scale: 2
    t.integer  "currency_code",     limit: 11
    t.decimal  "ent_declare_value",            precision: 20, scale: 2
    t.decimal  "app_value",                    precision: 20, scale: 2
    t.decimal  "last_reg_value",               precision: 20, scale: 2
  end

  create_table "fdn_ent_results", force: :cascade do |t|
    t.integer  "ent_id",            limit: 11
    t.integer  "row_template_id",   limit: 11
    t.decimal  "value",                        precision: 20, scale: 2
    t.integer  "lock_version",      limit: 11
    t.decimal  "exchange_rate",                precision: 20, scale: 2
    t.decimal  "foreign_currency",             precision: 20, scale: 2
    t.integer  "currency_code",     limit: 11
    t.decimal  "ent_declare_value",            precision: 20, scale: 2
    t.decimal  "app_value",                    precision: 20, scale: 2
    t.decimal  "last_reg_value",               precision: 20, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by",        limit: 11
    t.integer  "updated_by",        limit: 11
  end

  add_index "fdn_ent_results", ["ent_id"], name: "index_fdn_ent_results_on_ent_id", using: :btree
  add_index "fdn_ent_results", ["row_template_id"], name: "index_fdn_ent_results_on_row_template_id", using: :btree

  create_table "fdn_enterprise_histories", force: :cascade do |t|
    t.integer  "ent_id",               limit: 11
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "ent_code",             limit: 255
    t.string   "status",               limit: 255
    t.date     "start_date"
    t.date     "end_date"
    t.string   "legal",                limit: 255
    t.string   "ent_level_code",       limit: 255
    t.string   "parent_group_code",    limit: 255
    t.string   "currency_code",        limit: 255
    t.decimal  "reg_amt",                          precision: 20, scale: 2
    t.string   "address",              limit: 100
    t.string   "postal_code",          limit: 255
    t.integer  "latest_ppr_id",        limit: 11
    t.string   "ppr_status_code",      limit: 10
    t.string   "ent_type_code",        limit: 255
    t.string   "operate_status_code",  limit: 255
    t.string   "statistics_code",      limit: 255
    t.string   "main_ind_code",        limit: 255
    t.string   "ent_region_code",      limit: 255
    t.date     "reg_date"
    t.integer  "is_reg",               limit: 11
    t.integer  "is_outside_to_inside", limit: 11
    t.integer  "is_foreign",           limit: 11
    t.integer  "is_gov_inv_main_ind",  limit: 11
    t.integer  "main_inv_org_id",      limit: 11
    t.integer  "purpose",              limit: 11
    t.decimal  "exchange_rate",                    precision: 20, scale: 2
    t.integer  "individual",           limit: 11
    t.date     "purpose_to"
    t.decimal  "foreign_currency",                 precision: 20, scale: 2
    t.string   "purpose_from",         limit: 255
    t.decimal  "reg_amt_foreign",                  precision: 20, scale: 6
    t.integer  "gov_inv_id",           limit: 11
    t.string   "dept_name",            limit: 255
    t.integer  "dept_id",              limit: 11
    t.integer  "sasac_dept_id",        limit: 11
    t.integer  "is_direct_sup",        limit: 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by",           limit: 11
    t.integer  "updated_by",           limit: 11
  end

  create_table "fdn_enterprises", force: :cascade do |t|
    t.string   "ent_code",             limit: 255
    t.string   "status",               limit: 255
    t.date     "start_date"
    t.date     "end_date"
    t.string   "legal",                limit: 255
    t.string   "ent_level_code",       limit: 255
    t.string   "parent_group_code",    limit: 255
    t.string   "currency_code",        limit: 255
    t.decimal  "reg_amt",                          precision: 20, scale: 2
    t.string   "address",              limit: 100
    t.string   "postal_code",          limit: 255
    t.string   "ent_industry_code",    limit: 255
    t.integer  "latest_ppr_id",        limit: 11
    t.string   "ppr_status_code",      limit: 10
    t.string   "ent_type_code",        limit: 255
    t.string   "operate_status_code",  limit: 255
    t.string   "statistics_code",      limit: 255
    t.string   "main_ind_code",        limit: 255
    t.string   "ent_region_code",      limit: 255
    t.date     "reg_date"
    t.integer  "is_reg",               limit: 11
    t.integer  "is_outside_to_inside", limit: 11
    t.integer  "is_foreign",           limit: 11
    t.integer  "is_gov_inv_main_ind",  limit: 11
    t.integer  "main_inv_org_id",      limit: 11
    t.integer  "purpose",              limit: 11
    t.decimal  "exchange_rate",                    precision: 20, scale: 2
    t.integer  "individual",           limit: 11
    t.date     "purpose_to"
    t.decimal  "foreign_currency",                 precision: 20, scale: 2
    t.datetime "start_time"
    t.string   "purpose_from",         limit: 255
    t.decimal  "reg_amt_foreign",                  precision: 20, scale: 6
    t.integer  "gov_inv_id",           limit: 11
    t.string   "dept_name",            limit: 255
    t.integer  "dept_id",              limit: 11
    t.integer  "sasac_dept_id",        limit: 11
    t.integer  "is_direct_sup",        limit: 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by",           limit: 11
    t.integer  "updated_by",           limit: 11
  end

  add_index "fdn_enterprises", ["ent_code"], name: "fdn_enterprises_ind1", using: :btree
  add_index "fdn_enterprises", ["ent_level_code", "ent_type_code", "operate_status_code"], name: "fdn_enterprises_ind2", using: :btree
  add_index "fdn_enterprises", ["ent_region_code"], name: "fdn_enterprises_ind4", using: :btree
  add_index "fdn_enterprises", ["is_foreign"], name: "fdn_enterprises_ind5", using: :btree
  add_index "fdn_enterprises", ["main_ind_code"], name: "fdn_enterprises_ind3", using: :btree

  create_table "fdn_enterprises_industries", force: :cascade do |t|
    t.integer "ent_id",      limit: 11
    t.string  "industry_id", limit: 255
    t.integer "seq",         limit: 11
    t.integer "last_id",     limit: 11
  end

  add_index "fdn_enterprises_industries", ["ent_id", "industry_id", "seq"], name: "fdn_enterprises_industries_ind1", unique: true, using: :btree

  create_table "fdn_events", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.datetime "start_at"
    t.datetime "end_at"
    t.string   "resource_type", limit: 255
    t.integer  "resource_id",   limit: 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by",    limit: 11
    t.integer  "updated_by",    limit: 11
  end

  add_index "fdn_events", ["created_by", "start_at", "end_at"], name: "fdn_events_ind1", using: :btree
  add_index "fdn_events", ["resource_type", "resource_id"], name: "fdn_events_ind2", using: :btree

  create_table "fdn_file_resources", force: :cascade do |t|
    t.integer  "resource_id",      limit: 11
    t.string   "resource_type",    limit: 255
    t.integer  "ffx_file_size",    limit: 11
    t.string   "ffx_content_type", limit: 255
    t.string   "ffx_file_name",    limit: 255
    t.string   "display_name",     limit: 255
    t.string   "status",           limit: 255
    t.string   "file_desc",        limit: 255
    t.integer  "file_class_id",    limit: 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fdn_file_resources", ["resource_id", "resource_type", "file_class_id"], name: "fdn_file_resources_ind1", using: :btree

  create_table "fdn_file_templates", force: :cascade do |t|
    t.string   "resource_type",  limit: 80
    t.string   "template_class", limit: 50
    t.string   "template_name",  limit: 255
    t.string   "file_name",      limit: 255
    t.integer  "seq",            limit: 11
    t.string   "template_type",  limit: 30
    t.string   "status",         limit: 10
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fdn_file_templates", ["resource_type", "template_class", "template_type", "status"], name: "fdn_file_templates_ind1", using: :btree
  add_index "fdn_file_templates", ["resource_type"], name: "index_fdn_file_templates_on_resource_type", using: :btree

  create_table "fdn_homepages", force: :cascade do |t|
    t.integer  "dashboard_id",    limit: 11
    t.integer  "organization_id", limit: 11
    t.integer  "user_id",         limit: 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fdn_homepages", ["organization_id", "dashboard_id"], name: "index_fdn_homepages_on_organization_id_and_dashboard_id", using: :btree
  add_index "fdn_homepages", ["user_id", "dashboard_id"], name: "index_fdn_homepages_on_user_id_and_dashboard_id", using: :btree

  create_table "fdn_loggers", force: :cascade do |t|
    t.integer  "user_id",    limit: 11
    t.string   "ip",         limit: 20
    t.string   "controller", limit: 100
    t.string   "action",     limit: 100
    t.datetime "act_at"
  end

  add_index "fdn_loggers", ["controller", "action"], name: "fdn_loggers_ind1", using: :btree
  add_index "fdn_loggers", ["user_id"], name: "index_fdn_loggers_on_user_id", using: :btree

  create_table "fdn_lookups", force: :cascade do |t|
    t.string   "code",        limit: 255
    t.string   "type",        limit: 255
    t.string   "type_name",   limit: 255
    t.string   "value",       limit: 255
    t.string   "description", limit: 255
    t.string   "status",      limit: 255
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "seq",         limit: 11
    t.integer  "parent_id",   limit: 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by",  limit: 11
    t.integer  "updated_by",  limit: 11
  end

  add_index "fdn_lookups", ["parent_id"], name: "fdn_lookups_ind3", using: :btree
  add_index "fdn_lookups", ["type", "code"], name: "fdn_lookups_ind2", using: :btree
  add_index "fdn_lookups", ["type", "status"], name: "fdn_lookups_ind1", using: :btree

  create_table "fdn_menus", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.string   "code",           limit: 255
    t.string   "description",    limit: 255
    t.string   "title_img",      limit: 255
    t.string   "controller",     limit: 255
    t.string   "action",         limit: 255
    t.string   "params",         limit: 255
    t.string   "route_path",     limit: 255
    t.integer  "parent_id",      limit: 11
    t.integer  "children_count", limit: 11
    t.integer  "position",       limit: 11
    t.integer  "depth",          limit: 11
    t.string   "status",         limit: 1,   default: "Y"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by",     limit: 11
    t.integer  "updated_by",     limit: 11
  end

  add_index "fdn_menus", ["code"], name: "index_fdn_menus_on_code", using: :btree
  add_index "fdn_menus", ["parent_id"], name: "index_fdn_menus_on_parent_id", using: :btree
  add_index "fdn_menus", ["status"], name: "index_fdn_menus_on_status", using: :btree

  create_table "fdn_messages", force: :cascade do |t|
    t.string   "subject",           limit: 255
    t.text     "body"
    t.string   "sender_type",       limit: 255
    t.integer  "sender_id",         limit: 11
    t.integer  "reply_of",          limit: 11
    t.integer  "forward_from",      limit: 11
    t.integer  "group_id",          limit: 11
    t.integer  "trashed_by_sender", limit: 11,  default: 0
    t.string   "status",            limit: 255
    t.text     "receivers"
    t.string   "msg_type",          limit: 255
    t.integer  "msg_type_id",       limit: 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fdn_messages", ["sender_id", "sender_type", "trashed_by_sender", "status", "created_at"], name: "fdn_messages_ind1", using: :btree

  create_table "fdn_old_codes", force: :cascade do |t|
    t.string   "code",       limit: 255
    t.string   "name",       limit: 255
    t.string   "short_name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fdn_org_groups", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "org_ids",    limit: 255
    t.string   "desc",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by", limit: 11
    t.integer  "updated_by", limit: 11
  end

  create_table "fdn_org_hie_elements", force: :cascade do |t|
    t.integer  "org_hie_version_id", limit: 11
    t.integer  "parent_id",          limit: 11
    t.integer  "child_id",           limit: 11
    t.integer  "root_id",            limit: 11
    t.integer  "distance",           limit: 11
    t.integer  "seq",                limit: 11
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "org_hierarchy_id",   limit: 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fdn_org_hie_elements", ["end_time"], name: "fdn_org_hie_elements_ind6", using: :btree
  add_index "fdn_org_hie_elements", ["org_hie_version_id", "child_id", "distance"], name: "fdn_org_hie_elements_ind2", using: :btree
  add_index "fdn_org_hie_elements", ["org_hie_version_id", "parent_id", "distance"], name: "fdn_org_hie_elements_ind1", using: :btree
  add_index "fdn_org_hie_elements", ["org_hie_version_id", "root_id", "distance"], name: "fdn_org_hie_elements_ind3", using: :btree
  add_index "fdn_org_hie_elements", ["start_time", "end_time"], name: "fdn_org_hie_elements_ind4", using: :btree
  add_index "fdn_org_hie_elements", ["start_time"], name: "fdn_org_hie_elements_ind5", using: :btree

  create_table "fdn_org_hie_versions", force: :cascade do |t|
    t.integer  "org_hierarchy_id", limit: 11
    t.integer  "ver",              limit: 11
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "current_flag",     limit: 11
    t.integer  "resource_id",      limit: 11
    t.string   "resource_type",    limit: 255
    t.integer  "version",          limit: 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by",       limit: 11
    t.integer  "updated_by",       limit: 11
  end

  add_index "fdn_org_hie_versions", ["org_hierarchy_id", "current_flag"], name: "fdn_org_hie_versions_ind1", using: :btree
  add_index "fdn_org_hie_versions", ["org_hierarchy_id", "ver"], name: "fdn_org_hie_versions_ind2", using: :btree
  add_index "fdn_org_hie_versions", ["resource_id", "resource_type"], name: "fdn_org_hie_versions_ind3", using: :btree

  create_table "fdn_org_hierarchies", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "short_name", limit: 255
    t.string   "code",       limit: 255
    t.integer  "main_flag",  limit: 11
    t.integer  "org_id",     limit: 11
    t.integer  "version",    limit: 11
    t.string   "icon",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by", limit: 11
    t.integer  "updated_by", limit: 11
  end

  add_index "fdn_org_hierarchies", ["code"], name: "index_fdn_org_hierarchies_on_code", using: :btree
  add_index "fdn_org_hierarchies", ["main_flag"], name: "index_fdn_org_hierarchies_on_main_flag", using: :btree
  add_index "fdn_org_hierarchies", ["org_id"], name: "index_fdn_org_hierarchies_on_org_id", using: :btree

  create_table "fdn_org_shorts", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.integer  "organization_id", limit: 11
    t.integer  "act_dept_id",     limit: 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by",      limit: 11
    t.integer  "updated_by",      limit: 11
  end

  add_index "fdn_org_shorts", ["organization_id", "act_dept_id"], name: "fdn_org_shorts_ind1", using: :btree

  create_table "fdn_org_tree_changes", force: :cascade do |t|
    t.integer  "hierarchy_id", limit: 11
    t.datetime "change_time"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "created_by",   limit: 11
    t.integer  "updated_by",   limit: 11
  end

  create_table "fdn_organization_histories", force: :cascade do |t|
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "name",            limit: 255
    t.text     "description"
    t.string   "code",            limit: 255
    t.string   "short_name",      limit: 255
    t.string   "org_type",        limit: 255
    t.string   "resource_type",   limit: 255
    t.integer  "resource_id",     limit: 11
    t.integer  "lock_version",    limit: 11
    t.string   "purpose_from",    limit: 255
    t.decimal  "reg_amt_foreign",             precision: 20, scale: 6
    t.integer  "gov_inv_id",      limit: 11
    t.string   "dept_name",       limit: 255
    t.integer  "dept_id",         limit: 11
    t.integer  "sasac_dept_id",   limit: 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by",      limit: 11
    t.integer  "updated_by",      limit: 11
  end

  create_table "fdn_organizations", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.string   "description",   limit: 255
    t.string   "code",          limit: 255
    t.string   "short_name",    limit: 255
    t.string   "org_type",      limit: 255
    t.string   "resource_type", limit: 255
    t.integer  "resource_id",   limit: 11
    t.integer  "version",       limit: 11
    t.datetime "start_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by",    limit: 11
    t.integer  "updated_by",    limit: 11
  end

  add_index "fdn_organizations", ["code"], name: "index_fdn_organizations_on_code", using: :btree
  add_index "fdn_organizations", ["org_type"], name: "index_fdn_organizations_on_org_type", using: :btree
  add_index "fdn_organizations", ["resource_type", "resource_id"], name: "fdn_organizations_ind1", using: :btree

  create_table "fdn_party_orgs", force: :cascade do |t|
    t.string   "name",                   limit: 255
    t.string   "parent_name",            limit: 255
    t.date     "setting_date"
    t.integer  "party_members",          limit: 11
    t.integer  "pre_party_members",      limit: 11
    t.integer  "activist_party_members", limit: 11
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  create_table "fdn_predef_opinion_templates", force: :cascade do |t|
    t.string   "type_code",  limit: 255
    t.string   "content",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fdn_predef_opinion_templates", ["type_code"], name: "index_fdn_predef_opinion_templates_on_type_code", using: :btree

  create_table "fdn_predef_opinions", force: :cascade do |t|
    t.string   "type_code",  limit: 255
    t.string   "content",    limit: 255
    t.integer  "user_id",    limit: 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fdn_predef_opinions", ["user_id", "type_code"], name: "fdn_predef_opinions_ind1", using: :btree

  create_table "fdn_received_messages", force: :cascade do |t|
    t.integer  "message_id",          limit: 11
    t.integer  "receiver_id",         limit: 11
    t.string   "receiver_type",       limit: 255
    t.integer  "trashed_by_receiver", limit: 11,  default: 0
    t.integer  "read",                limit: 11,  default: 0
    t.datetime "read_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fdn_received_messages", ["message_id"], name: "index_fdn_received_messages_on_message_id", using: :btree
  add_index "fdn_received_messages", ["receiver_id", "receiver_type", "trashed_by_receiver", "created_at", "read"], name: "fdn_received_messages_ind1", using: :btree

  create_table "fdn_regions", force: :cascade do |t|
    t.string   "region_code", limit: 255
    t.string   "country",     limit: 255
    t.string   "province",    limit: 255
    t.string   "city",        limit: 255
    t.string   "district",    limit: 255
    t.integer  "parent_id",   limit: 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fdn_regions", ["country", "province", "city"], name: "fdn_regions_ind1", using: :btree
  add_index "fdn_regions", ["country"], name: "index_fdn_regions_on_country", using: :btree
  add_index "fdn_regions", ["parent_id"], name: "index_fdn_regions_on_parent_id", using: :btree
  add_index "fdn_regions", ["region_code"], name: "index_fdn_regions_on_region_code", using: :btree

  create_table "fdn_rights", force: :cascade do |t|
    t.string   "code",        limit: 255
    t.string   "type_code",   limit: 255
    t.string   "description", limit: 255
    t.string   "app_code",    limit: 255
    t.string   "controller",  limit: 255
    t.string   "action",      limit: 255
    t.integer  "menu_id",     limit: 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fdn_rights", ["app_code"], name: "index_fdn_rights_on_app_code", using: :btree
  add_index "fdn_rights", ["menu_id"], name: "index_fdn_rights_on_menu_id", using: :btree
  add_index "fdn_rights", ["type_code", "code"], name: "fdn_rights_ind1", using: :btree

  create_table "fdn_roles", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.string   "code",            limit: 255
    t.string   "description",     limit: 255
    t.integer  "organization_id", limit: 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by",      limit: 11
    t.integer  "updated_by",      limit: 11
  end

  add_index "fdn_roles", ["code"], name: "index_fdn_roles_on_code", using: :btree
  add_index "fdn_roles", ["organization_id"], name: "index_fdn_roles_on_organization_id", using: :btree

  create_table "fdn_templates", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "code",       limit: 255
    t.text     "content"
    t.integer  "menu_id",    limit: 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fdn_templates", ["code"], name: "index_fdn_templates_on_code", using: :btree
  add_index "fdn_templates", ["menu_id"], name: "index_fdn_templates_on_menu_id", using: :btree

  create_table "fdn_user_groups", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "contact_ids", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by",  limit: 11
    t.integer  "updated_by",  limit: 11
  end

  add_index "fdn_user_groups", ["created_by"], name: "index_fdn_user_groups_on_created_by", using: :btree

  create_table "fdn_user_informations", force: :cascade do |t|
    t.string   "full_name",   limit: 255
    t.string   "tel",         limit: 255
    t.string   "mobile",      limit: 255
    t.string   "fax",         limit: 255
    t.string   "address",     limit: 255
    t.string   "postal_code", limit: 255
    t.string   "email",       limit: 255
    t.string   "post",        limit: 255
    t.string   "im_soft",     limit: 255
    t.text     "memo"
    t.integer  "user_id",     limit: 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by",  limit: 11
    t.integer  "updated_by",  limit: 11
  end

  add_index "fdn_user_informations", ["user_id", "full_name"], name: "fdn_user_informations_ind1", using: :btree

  create_table "fdn_users", force: :cascade do |t|
    t.string   "username",            limit: 255,               null: false
    t.string   "encrypted_password",  limit: 255,               null: false
    t.string   "password_salt",       limit: 255,               null: false
    t.string   "persistence_token",   limit: 255,               null: false
    t.string   "single_access_token", limit: 255,               null: false
    t.string   "perishable_token",    limit: 255,               null: false
    t.string   "resource_type",       limit: 255
    t.integer  "resource_id",         limit: 11
    t.string   "status",              limit: 255
    t.string   "ghost",               limit: 255, default: "N"
    t.integer  "login_count",         limit: 11,  default: 0,   null: false
    t.integer  "failed_login_count",  limit: 11,  default: 0,   null: false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip",    limit: 255
    t.string   "last_login_ip",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by",          limit: 11
    t.integer  "updated_by",          limit: 11
  end

  add_index "fdn_users", ["persistence_token"], name: "index_fdn_users_on_persistence_token", using: :btree
  add_index "fdn_users", ["resource_type", "resource_id"], name: "fdn_users_ind1", using: :btree
  add_index "fdn_users", ["status"], name: "index_fdn_users_on_status", using: :btree
  add_index "fdn_users", ["username"], name: "index_fdn_users_on_username", using: :btree

  create_table "fdn_widget_actions", force: :cascade do |t|
    t.integer  "widget_id",  limit: 11
    t.string   "value",      limit: 255
    t.string   "icon",       limit: 255
    t.text     "href"
    t.text     "onclick"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fdn_widget_actions", ["widget_id"], name: "index_fdn_widget_actions_on_widget_id", using: :btree

  create_table "fdn_widgets", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "code",       limit: 255
    t.string   "url",        limit: 255
    t.string   "title",      limit: 255
    t.integer  "bold",       limit: 11
    t.integer  "higher",     limit: 11
    t.string   "params",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by", limit: 11
    t.integer  "updated_by", limit: 11
  end

  add_index "fdn_widgets", ["code"], name: "index_fdn_widgets_on_code", using: :btree

  create_table "fdn_work_calendars", force: :cascade do |t|
    t.integer  "year",        limit: 11
    t.integer  "qtr",         limit: 11
    t.integer  "month",       limit: 11
    t.integer  "day_of_week", limit: 11
    t.date     "day_name"
    t.integer  "is_working",  limit: 11
    t.integer  "is_weekend",  limit: 11
    t.integer  "is_holiday",  limit: 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fdn_work_calendars", ["year", "month"], name: "fdn_work_calendars_ind1", using: :btree

  create_table "oa_sent_documents", force: :cascade do |t|
    t.string   "doc_type_code",      limit: 255
    t.string   "secret_level_code",  limit: 255
    t.string   "doc_urgency_code",   limit: 255
    t.string   "doc_word_code",      limit: 255
    t.integer  "year",               limit: 11
    t.integer  "no",                 limit: 11
    t.string   "title",              limit: 255
    t.text     "content"
    t.integer  "organization_id",    limit: 11
    t.string   "pri_sent_org_name",  limit: 255
    t.string   "cc_sent_org_name",   limit: 255
    t.string   "ccr_sent_org_name",  limit: 255
    t.datetime "sign_time"
    t.string   "keyword",            limit: 255
    t.text     "memo"
    t.integer  "print_org_id",       limit: 11
    t.datetime "print_time"
    t.integer  "print_count",        limit: 11
    t.integer  "print_template_id",  limit: 11
    t.datetime "sent_time"
    t.string   "status",             limit: 255
    t.string   "gzw_doc_level_code", limit: 255
    t.integer  "no_arch",            limit: 11
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by",         limit: 11
    t.integer  "updated_by",         limit: 11
  end

  create_table "old_codes_organizations", id: false, force: :cascade do |t|
    t.integer "old_code_id",     limit: 11
    t.integer "organization_id", limit: 11
  end

  create_table "rights_roles", id: false, force: :cascade do |t|
    t.integer "right_id", limit: 11
    t.integer "role_id",  limit: 11
  end

  add_index "rights_roles", ["right_id", "role_id"], name: "rights_roles_ind1", unique: true, using: :btree

  create_table "roles_users", id: false, force: :cascade do |t|
    t.integer "role_id", limit: 11
    t.integer "user_id", limit: 11
  end

  add_index "roles_users", ["role_id", "user_id"], name: "roles_users_ind1", unique: true, using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255, null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "simple_captcha_data", force: :cascade do |t|
    t.string   "key",        limit: 40
    t.string   "value",      limit: 6
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "simple_captcha_data", ["key"], name: "idx_key", using: :btree

  create_table "users_enterprises", id: false, force: :cascade do |t|
    t.integer "user_id",       limit: 11
    t.integer "enterprise_id", limit: 11
  end

  add_index "users_enterprises", ["user_id", "enterprise_id"], name: "users_enterprises_ind1", unique: true, using: :btree

end
