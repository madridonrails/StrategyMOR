set :application, "strategygem"
set :repository,  "https://larry.aspgems.com:8083/ASPgems/strategygem/trunk"
set :deploy_to, "/home/strategygem/ASPgems/#{application}"
set :user, "strategygem"

# deployment method
set :deploy_via, :checkout

# If you aren't using Subversion to manage your source code, specify
# your SCM below:

# Subversion access data variables
set(:scm_username) do
  Capistrano::CLI.ui.ask "Give me a svn user: "
end
set(:scm_password) do
  Capistrano::CLI.ui.ask "Give me a svn password for user #{scm_username}: "
end

set :database, "strategygem"
set :database_username, "strategygem"
set(:database_password) do
  Capistrano::CLI.ui.ask "Give me a database password for user #{database_username}: "
end
set :database_host, "localhost"

set :mongrel_start_port, 8020
set :mongrel_servers, 1
set :mongrel_username, "strategygem"
set :mongrel_group, "users"
set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"

role :app, "acens.aspgems.com"
role :web, "acens.aspgems.com"
role :db,  "acens.aspgems.com", :primary => true

