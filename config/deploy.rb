set :stage, 'production'

set :application, 'depot'
set :repo_url, 'git@bitbucket.org:rajatbansal/depot.git'
set :pty, true
set :scm, 'git'
set :deploy_via, :remote_cache
set :rails_env, 'production'

server '35.164.73.110',  user: 'rb', roles: %w(app web db worker)


set :deploy_to, '/var/www/apps/depot'
set :branch, ENV['BRANCH'] || 'master'

set :keep_releases, 5

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('tmp/pids', 'tmp/cache', 'tmp/sockets', 'log', 'public/assets', 'public/system')

set :keep_assets, 2

set :whenever_roles, [:worker]
set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }

set :delayed_job_roles, [:worker]


namespace :passenger do
  task :restart do
    on roles(:app) do
      within current_path do
        execute :touch, :'tmp/restart.txt'
      end
    end
  end
end
namespace :database do
  desc 'create database'
  task :create do
    on roles(:db), in: :parallel do
      within current_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, :rake, 'db:create'
        end
      end
    end
  end

  desc 'migration'
  task :migrate do
    on roles(:db), in: :parallel do
      within current_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, :rake, 'db:migrate'
        end
      end
    end
  end

  desc 'seed'
  task :seed do
    on roles(:db), in: :parallel do
      within current_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, :rake, 'db:seed'
        end
      end
    end
  end
end
after 'deploy', 'passenger:restart'
