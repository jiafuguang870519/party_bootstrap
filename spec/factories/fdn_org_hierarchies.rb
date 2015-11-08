#coding: utf-8
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  factory :cq_org_hierarchy, :class => 'Fdn::OrgHierarchy' do
    name '产权组织架构'
    short_name '产'
    code 'GZW_MAIN'
    main_flag 1
    icon 'badge-primary'
  end

  #factory :kb_org_hierarchy, :class => 'Fdn::OrgHierarchy' do
  #  name '快报组织架构'
  #  short_name '快'
  #  code 'KB_MAIN'
  #  main_flag 2
  #  icon 'badge-info'
  #end
  #
  #factory :ys_org_hierarchy, :class => 'Fdn::OrgHierarchy' do
  #  name '预算组织架构'
  #  short_name '预'
  #  code 'YS_MAIN'
  #  main_flag 3
  #  icon 'badge-success'
  #end
  #
  #factory :nb_org_hierarchy, :class => 'Fdn::OrgHierarchy' do
  #  name '年报组织架构'
  #  short_name '年'
  #  code 'NB_MAIN'
  #  main_flag 4
  #  icon 'badge-warning'
  #end
  #
  #factory :js_org_hierarchy, :class => 'Fdn::OrgHierarchy' do
  #  name '决算组织架构'
  #  short_name '决'
  #  code 'JS_MAIN'
  #  main_flag 5
  #  icon 'badge-danger'
  #end





  #factory :main_version, :class => 'Fdn::OrgHieVersion' do
  #  association :org_hierarchy, factory: :main_org_hierarchy
  #  ver 1
  #  start_date '2010-1-1'
  #  current_flag 1
  #end

  factory :main_element, :class => 'Fdn::OrgHieElement' do
    ignore do
      p nil
      c nil
      r nil
      d nil
    end

    start_time {Time.now}
    end_time '2999-12-31 23:59:59'
    parent { p }
    child { c }
    root { r }
    distance { d }
  end

end

