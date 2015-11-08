json.array!(@fdn_party_orgs) do |fdn_party_org|
  json.extract! fdn_party_org, :id, :name, :parent_name, :setting_date, :party_members, :pre_party_members, :activist_party_members
  json.url fdn_party_org_url(fdn_party_org, format: :json)
end
