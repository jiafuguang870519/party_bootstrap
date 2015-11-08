#coding: utf-8
FactoryGirl.define do
  factory :user_info, :class => 'Fdn::UserInformation' do
    full_name '工作人员'
  end

  factory :ghost_admin_info, :class => 'Fdn::UserInformation' do
    full_name '隐藏管理员'
  end

  factory :adv_user_info, :class => 'Fdn::UserInformation' do
    full_name '高级用户'
  end

  factory :admin_user_info, :class => 'Fdn::UserInformation' do
    full_name '管理员'
  end

  factory :cwys_user_info, :class => 'Fdn::UserInformation' do
    full_name '财务'
  end

  factory :leader_info, :class => 'Fdn::UserInformation' do
    full_name '领导'
  end

  factory :pt_user_info, :class => 'Fdn::UserInformation' do
    full_name '纳税'
  end

  factory :fin_user_info, :class => 'Fdn::UserInformation' do
    full_name '财务'
  end

end
