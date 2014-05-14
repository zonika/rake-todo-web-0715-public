require 'spec_helper'

describe 'Rakefile' do
  it 'defines the starter task hello_world' do
    expect(Rake::Task[:hello_rake]).to be_an_instance_of(Rake::Task)
  end

  describe 'default task' do
    it 'defines a default task hello_world' do
      expect(Rake::Task[:default]).to be_an_instance_of(Rake::Task)
    end

    it 'outputs Hello, from default task' do
      expect($stdout).to receive(:puts).with("Hello, from default task!")
      Rake::Task[:default].invoke()
    end
  end

  describe 'environment task' do
    before do
      Rake::Task[:environment].invoke()
    end

    it 'loads the environment' do
      # If the environment was successfully loaded the following
      # constants should be defined.
      expect(defined?(User)).to be
      expect(defined?(Todo)).to be

      # If you think about it, another thing we could have tested
      # is if the Rakefile includes a call to require environment
      # but that seems to be testing implementation, how
      # the environment was loaded, rather then the implication
      # of the environment being loaded, namely, the existence
      # of our two classes.
    end
  end

  describe 'upcoming_todos task' do
    let(:task){Rake::Task[:upcoming_todos]}

    it 'defines a prerequisite of environment' do
      expect(task.prerequisites).to include("environment")
    end

    it 'calls User.with_upcoming_todos' do
      # Another fun thing to test about rake tasks is that they execute
      # the code you intend.
      expect(User).to receive(:with_upcoming_todos).and_return(["A User"])
      expect($stdout).to receive(:puts).with("Emailing A User")

      # Now we trigger our task
      task.invoke()
    end
  end  

  describe 'overdue_todos task' do
    let(:task){Rake::Task[:overdue_todos]}

    it 'defines a prerequisite of environment' do
      expect(task.prerequisites).to include("environment")
    end

    it 'calls User.with_overdue_todos' do
      expect(User).to receive(:with_overdue_todos).and_return(["A User"])
      expect($stdout).to receive(:puts).with("Emailing A User")

      task.invoke()
    end
  end

  describe "todos" do
    describe "mark_overdue" do
      let(:task){Rake::Task['todos:mark_overdue']}

      it 'defines a prerequisite of environment' do
        expect(task.prerequisites).to include("environment")
      end

      it 'calls Todo.mark_overdue' do
        expect(Todo).to receive(:mark_overdue)

        task.invoke()
      end
    end

    describe "mark_upcoming" do
      let(:task){Rake::Task['todos:mark_upcoming']}

      it 'defines a prerequisite of environment' do
        expect(task.prerequisites).to include("environment")
      end

      it 'calls Todo.mark_upcoming' do
        expect(Todo).to receive(:mark_upcoming)

        task.invoke()
      end
    end
  end

  describe 'console' do
    let(:task){Rake::Task['console']}

    it 'defines a prerequisite of environment' do
      expect(task.prerequisites).to include("environment")
    end

    it 'includes a description' do
      # I can't find a way to query the task for it's description programmatically.
      # There is a method comment that should do it, but it is not working.
      # There is also a method called add_description that modifies the comment
      # but it isn't loading the corresponding description.

      # This should work, but doesn't
      # expect(task.comment).to eq("Loads an interactive console.")

      # So I'll do this instead.
      rakefile = File.read("Rakefile")
      expect(rakefile).to include("desc \"Loads an interactive console.\"")

      # Or this.
      rake_t = `rake -T` # This executes a system command and captures output.
      expect(rake_t).to match(/rake console\s+# Loads an interactive console/)      
    end
  end

  describe 'user' do
    describe 'send_summary' do
      let(:task){Rake::Task['user:send_summary']}

      it 'defines a prerequisite of environment' do
        expect(task.prerequisites).to include("environment")
      end

      it 'accepts an argument for the user email' do
        expect(task.arg_names).to include(:email)
      end

      it 'emails the user a summary' do
        expect($stdout).to receive(:puts).with("Sending summary to user with student@flatironschool.com")
        task.invoke("student@flatironschool.com")
      end
    end

    # describe "todo_reminder" do
    #   it 'defines a prerequisite of environment'
    #   it 'uses an ENV variable of EMAIL'
    #   it 'emails the user a todo reminder'
    # end
  end
end