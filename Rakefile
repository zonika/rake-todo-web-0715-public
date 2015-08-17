# This is an example of a Rake Task called "hello_rake"
task :hello_rake do
  puts "Hello, from rake"
end

# Define new tasks below
task :default do
  puts "Hello, from default task!"
end

task :environment do
  require_relative './config/environment'
end

task :upcoming_todos => [:environment] do
  User.with_upcoming_todos.each do |user|
    puts "Emailing #{user}"
  end
end

task :overdue_todos => [:environment] do
  User.with_overdue_todos.each do |user|
    puts "Emailing #{user}"
  end
end

namespace :todos do
  task :mark_overdue => [:environment] do
    Todo.mark_overdue
  end

  task :mark_upcoming => [:environment] do
    Todo.mark_upcoming
  end
end

desc "Loads an interactive console."
task :console => [:environment] do
  load './bin/console'
  exit
end

namespace :user do
  desc "Send a summary to a User"
  task :send_summary, [:email] => [:environment] do |t, args|
    # [email] is the argument array
    # [environment] is the prerequisite task array
    puts "Sending summary to user with #{args[:email]}"
  end
end
