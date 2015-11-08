# coding: utf-8
# Read about factories at https://github.com/thoughtbot/factory_girl
FactoryGirl.define do
  factory :dept, :class => 'Fdn::Dept' do

    trait :in do
      internal 0
    end

    trait :ex do
      internal 1
    end

    factory :gzw, traits: [:in] do
      type_code 'GZW'
    end

    factory :gov, traits: [:in] do
      type_code 'GOV'
    end

  end

  factory :enterprise, :class=> 'Fdn::Enterprise' do
    ent_code {Fdn::OrgCode.new.get_org_code((Random.rand(900000000)+100000000).to_s)}
    is_foreign 0
    is_reg 0
    ent_level_code 1
    reg_amt 10000

    factory :one_lvl_ent do
      after(:build) do |obj, evaluator|
        obj.build_organization(FactoryGirl.attributes_for(:one_lvl_org))
      end

      factory :two_lvl_ent do
        ent_level_code 2
      end

      factory :thi_lvl_ent do
        ent_level_code 3
      end
    end
  end


  factory :org_gzw, :class => 'Fdn::Organization' do
    trait :gzw_resource do
      association :resource, factory: :gzw
    end

    trait :gov_resource do
      association :resource, factory: :gov
    end


    factory :nj_soft_gzw, traits: [:gzw_resource] do
      code '320100'
      name '国资委'
      short_name '国资委'
    end

  end

  factory :fdn_enterprise, :class => 'Fdn::Enterprise' do

    factory :one_lvl do
      ent_code '111111111'
      ent_level_code 1
    end

    factory :one_lvl_other do
      ent_code '222222222'
      ent_level_code 1
    end

    factory :two_lvl do
      ent_code '333333333'
      ent_level_code 2
    end


  end

  factory :fdn_organization, :class => 'Fdn::Organization' do

    factory :one_lvl_org1 do
      name '一级企业1'
      short_name '一级企业1'
      code '111111111'
    end

    factory :one_lvl_org2 do
      name '一级企业2'
      short_name '一级企业2'
      code '222222222'
    end

    factory :two_lvl_org do
      name '二级企业'
      short_name '二级企业'
      code '333333333'
    end
  end

end
