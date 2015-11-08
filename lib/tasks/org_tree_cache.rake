#coding: utf-8
desc '预缓存组织树'
task :org_tree_cache => :environment do
  @show_orgs = Fdn::Organization.first.with_hierarchy.all_descendants
  @show_orgs << Fdn::Organization.first
  @org_trees = @show_orgs.map { |m| {:id => m.id, :parent => (m.parent.nil? ? "#":m.parent.id), :text => m.name } }
  path = "#{Rails.root}/public/org_tree.json"
  file = File.new(path, "w")
  file.puts @org_trees.to_json
  file.close
end