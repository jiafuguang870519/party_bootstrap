#coding: utf-8
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :fdn_menu, :class => 'Fdn::Menu' do

    trait :init_pass do
      created_at Time.now
      updated_at Time.now
    end

    factory :home, :traits => [:init_pass] do
      name '首页'
      code 'home'
      parent_id 0
      seq 10
    end

    factory :workspace, :traits => [:init_pass] do
      name '我的工作台'
      code 'workspace'
      parent_id 0
      seq 20
    end

    factory :dashboard, :traits => [:init_pass] do
      name '仪表盘'
      code 'dashboard'
      parent_id 0
      seq 30
    end

    factory :project, :traits => [:init_pass] do
      name '项目'
      code 'dashboard'
      parent_id 0
      seq 40
    end

    factory :wiki, :traits => [:init_pass] do
      name '知识库'
      code 'wiki'
      parent_id 0
      seq 50
    end

    factory :communication, :traits => [:init_pass] do
      name '信息与交流'
      code 'communication'
      parent_id 0
      seq 60
    end

    factory :notification, :traits => [:init_pass] do
      name '信箱'
      code 'notification'
      parent_id 0
      seq 70
    end

    factory :recycling, :traits => [:init_pass] do
      name '回收站'
      code 'Recycling'
      parent_id 0
      seq 80
    end

    factory :setting, :traits => [:init_pass] do
      name '系统设置'
      code 'setting'
      parent_id 0
      seq 90
    end

  end
end