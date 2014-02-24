---
tags: rake
language: ruby
---

# Rake TODO

Rake is a DSL written in Ruby designed as a build system and generic task runner. It was built by the late and great [Jim Weirich](http://en.wikipedia.org/wiki/Jim_Weirich).

The history of why we need Rake relates to [Make](http://en.wikipedia.org/wiki/Make_software). For the most part, especially within Rails, we use Rake for its task syntax. A popular alternative to Rake in this context is [Thor](http://whatisthor.com/).

## Installing Rake

Most ruby environments come with rake installed, but just in case, run these in
your terminal.

```
gem install rake
```

And you should see:

```
Successfully installed rake-10.1.1
Installing ri documentation for rake-10.1.1
```

Confirm the executable by trying:

```
rake --version
```

You should see:

```
rake, version 10.1.1
```

## Rakefile

Rake is powered by tasks defined or loaded within a `Rakefile` at the top of 
a directory.

First of all, there is no special format for a Rakefile. A Rakefile contains 
executable Ruby code. Anything legal in a ruby script is allowed in a Rakefile.

Now that we understand there is no special syntax in a Rakefile, there are some
conventions that are used in a Rakefile that are a little unusual in a typical
Ruby program.  Since a Rakefile is tailored to specifying tasks and actions, 
the idioms used in a Rakefile are designed to support that.

So, what goes into a Rakefile?

## Tasks

Tasks are the main unit of work in a Rakefile.  Tasks have a name
(usually given as a symbol or a string), a list of prerequisites (more
symbols or strings) and a list of actions (given as a block).

A task is declared by using the `task` method. `task` takes a single
parameter that is the name of the task.

```ruby
task :hello_rake do
  puts "Hello, from rake"
end
```

You run a particular rake task by invoking the rake command with the task name
from your terminal.

```
rake hello_rake
```

You should see:

```
Hello, from rake
```

## Testing Rake

Rake provides programmatic access to the tasks defined in the Rakefile 
via [`Rake::Task`](http://rake.rubyforge.org/classes/Rake/Task.html). There are
a lot of useful things you can do with this, one of which is testing!

Included is a `spec/rakefile_spec` that will test your progression through this
tutorial. Read it, it's fun. Also, checkout how the `Rakefile` was loaded into 
the test suite in the `spec_helper`.

You also have a console you can run that will load your environment and your Rakefile so you can play with the Rake::Task api. `bin/console` to try it out!

## Default Task

You can specify a default rake task within a rake file by naming it `default`.

First, run `rspec` and see the error we get without the default task defined.

```
  1) Rakefile default task defines a default task hello_world
     Failure/Error: expect(Rake::Task[:default]).to be_an_instance_of(Rake::Task)
     RuntimeError:
       Don't know how to build task 'default'
     # ./spec/rakefile_spec.rb:10:in `block (3 levels) in <top (required)>'

```

Within the test, we tried accessing the task `default` using the [Rake:Task.[]](http://rake.rubyforge.org/classes/Rake/Task.html#M000129).
Had that task been defined, it would have returned an instance of `Rake::Task`.

You can programmatically execute a rake task via the [invoke](http://rake.rubyforge.org/classes/Rake/Task.html#M000119) method.
The next test does this to ensure you've defined the default task correctly.

Add this to your `Rakefile`.

```ruby
task :default do
  puts "Hello, from the default rake task"
end
```

Run it by simply invoking `rake` from your terminal. Run `rspec` again and you 
should be on the next error.

## Task Prerequisites

A nice thing about rake is that tasks can define prerequisite tasks. Imagine
two tasks, `upcoming_todos` and `overdue_todos`, that relate to emailing users
with their upcoming and overdue todos respectively. Both these tasks will
require loading the environment defined in `config/environment.rb`.

You can define a task, `environment` that consolidates loading the environment.

Add this to your `Rakefile`.

```ruby
task :environment do
  require_relative './config/environment'
end
```

After adding this, run `rspec`.
 
It's a simple task, it simply loads the environment. Now, we can define a task
that relies on this task for being run.

```ruby
task :upcoming_todos => [:environment] do
  User.with_upcoming_todos.each do |user|
    puts "Emailing #{user}"
  end
end
```

The prerequisite syntax is `:task_name => [:prerequisite, :task_names]`. You can specify more than one task.

Add another task yourself called `overdue_todos` that has a prerequisite of the
environment and calls the `with_overdue_todos` on the `User` class in a 
similar fashion as the above task

## Namespaces

It's useful to group tasks together and rake provides a `namespace` mechanism
for this.

Add this to your `Rakefile`

```ruby
namespace :todos do
  task :mark_overdue => [:environment] do
    Todo.mark_overdue
  end
end
```

When the task `mark_overdue` is within a namespace of `todos` its name becomes
`todos:mark_overdue`. You cannot refer to the task as `mark_overdue`. Both from
the command line, and programmatically, the task is `todos:mark_overdue`.

From your terminal: `rake todos:mark_overdue`

From Ruby: `Rake::Task['todos:mark_overdue']`

Add a task `mark_upcoming` in the `todos` namespace that behaves like the 
`mark_overdue` task.

## Descriptions

Rake provides a nice way to describe the functionality of tasks within a task.
The `desc` method accepts a string that describes the task adjacent to it.

Add this to your `Rakefile`

```ruby
desc "Loads an interactive console."
task :console => [:environment] do
  load './bin/console'
  exit
end
```

You can see a list of all tasks with a description from the terminal: `rake -T`.

Checkout the tests related to the console task for some interesting ways to test.

You can now also load your console via `rake console`.

## Arguments

Finally, there are two ways to have a rake task take arguments. The first is 
through the DSL, here are a few examples of how you can combine prerequisites and task arguments.

```ruby
task :my_task, :arg1, :arg2 do |t, args| 
#t is the task itself, args a hash like object of arguments.
  puts "Args were: #{args}"
end

task :invoke_my_task do
  Rake.application.invoke_task("my_task[1, 2]")
end

# or if you prefer this syntax...
task :invoke_my_task_2 do
  Rake::Task[:my_task].invoke(3, 4)
end

# a task with prerequisites passes its 
# arguments to it prerequisites
task :with_prerequisite, :arg1, :arg2, :needs => :prerequisite_task

# equivalently...my preferred syntax.
task :with_prerequisite_2, [:arg1, :arg2] => :prerequisite_task

# to specify default values, 
# we take advantage of args being a Rake::TaskArguments object
task :with_defaults, :arg1, :arg2 do |t, args|
  args.with_defaults(:arg1 => :default_1, :arg2 => :default_2)
  puts "Args with defaults were: #{args}"
end
```

And then, from the terminal:

```
> rake my_task[1,2]
Args were: {:arg1=>"1", :arg2=>"2"}

> rake "my_task[1, 2]"
Args were: {:arg1=>"1", :arg2=>"2"}

> rake invoke_my_task
Args were: {:arg1=>"1", :arg2=>"2"}

> rake invoke_my_task_2
Args were: {:arg1=>3, :arg2=>4}

> rake with_prerequisite[5,6]
Args were: {:arg1=>"5", :arg2=>"6"}

> rake with_prerequisite_2[7,8]
Args were: {:arg1=>"7", :arg2=>"8"}

> rake with_defaults
Args with defaults were: {:arg1=>:default_1, :arg2=>:default_2}

> rake with_defaults['x','y']
Args with defaults were: {:arg1=>"x", :arg2=>"y"}
```

I enjoy the following syntax.

Add this to your `Rakefile`.

```ruby
namespace :user do
  desc "Send a summary to a User"
  task :send_summary, [:email] => [:environment] do |t, args|
    # [email] is the argument array
    # [environment] is the prerequisite task array
    puts "Sending summary to user with #{args[:email]}"
  end
end
```

Run `rake -T`, it shows you how to send the argument via terminal.

```
rake user:send_summary[email]  # Send a summary to a User
```

Try from your terminal: `rake user:send_summary[student@flatironschool.com]`

```
rake user:send_summary[student@flatironschool.com]
Sending summary to user with student@flatironschool.com
```

Another way to accept arguments is to simply send `ENV` arguments through your
shell.

Define the task normally (add this to your `Rakefile` in the user namespace)

```ruby
task :todo_reminder => [:environment] do
  # ENV is a constant that represents all of our environmental variables
  # set through our shell. It stores things like your PATH and such. It is a
  # Hash like object.
  my_ruby_home = ENV["MY_RUBY_HOME"]
  puts "ENV includes #{my_ruby_home}"

  puts "Sending todo reminder to #{ENV["EMAIL"]}"
end
```

When invoking the task, you simply pass along a temporary ENV variable 
assignment.

`rake user:todo_reminder EMAIL=student@flatironschool.com`. 

This becomes harder to test but still possible. Try to write a test.

## Resources

http://lukaszwrobel.pl/blog/rake-tutorial
http://railscasts.com/episodes/66-custom-rake-tasks
http://jasonseifer.com/2010/04/06/rake-tutorial?again
http://www.rubycoloredglasses.com/2012/01/example-rake-task/
http://pivotallabs.com/how-i-test-rake-tasks/
http://robots.thoughtbot.com/test-rake-tasks-like-a-boss
