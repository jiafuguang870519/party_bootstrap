#coding: utf-8
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :fdn_user, :class => 'Fdn::User' do
    username 'user'

    trait :init_pass do
      password '11111'
      password_confirmation '11111'
    end

    factory :admin_user, :traits => [:init_pass] do
      username 'admin'
    end

    factory :ghost_admin, :traits => [:init_pass] do
      username 'ghost'
      ghost 'Y'
    end


    factory :leader_user, :traits => [:init_pass] do
      username 'leader'
    end

    factory :adv_user, :traits => [:init_pass] do
      username 'manager'
    end

    factory :fin_user, :traits => [:init_pass] do
      username 'fin_user'
    end

    factory :pt_user, :traits => [:init_pass] do
      username 'pt_user'
    end




  end
end