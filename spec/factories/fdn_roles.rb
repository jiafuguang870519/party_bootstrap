#coding: utf-8
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :fdn_role, :class => 'Fdn::User' do
    ignore do
      count 1
    end

    name 'user'
    code 'user'

    trait :in do
      #predef_flag 1
    end

    trait :ex do
      #predef_flag 0
    end

    factory :admin_role, traits: [:in] do
      name '管理员'
      code 'admin'
    end

    factory :fin_user_role, traits: [:in] do
      name  '财务人员'
      code  'CWRY'
    end

    factory :pt_user_role, traits: [:in] do
      name  '纳税人员'
      code  'NSRY'
    end

    factory :user_role, traits: [:in] do
      name  '工作人员'
      code  'GZRY'
    end

    factory :manager_role, traits: [:in] do
      name  '部长'
      code  'BZ'
    end

    factory :leader_role, traits: [:in] do
      name  '领导'
      code  'LD'
    end

    factory :ghost_role, traits: [:in] do
      name  '隐藏管理员'
      code  'ghost'
    end

  end
end
