# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

Rails.application.load_tasks

if Rails.env.development?
  require 'annotate'

  Annotate.set_defaults(models: true, show_indexes: true)
  Annotate.load_tasks
end
