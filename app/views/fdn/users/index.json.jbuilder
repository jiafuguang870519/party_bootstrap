json.array!(@fdn_users) do |fdn_user|
  json.extract! fdn_user, :id
  json.url fdn_user_url(fdn_user, format: :json)
end
