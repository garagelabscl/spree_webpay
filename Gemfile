source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

spree_opts = { github: "spree/spree", branch: "main"}
gem "spree", spree_opts
gem "spree_auth_devise", { github: "spree/spree_auth_devise", branch: "main" }
gem 'rails-controller-testing'

gem 'rubocop', require: false
gem 'rubocop-rspec', require: false
gem "transbank-sdk"

gemspec
