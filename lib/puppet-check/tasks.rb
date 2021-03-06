begin
  require 'rake/tasklib'
rescue LoadError
  raise 'Rake is not installed and you are attempting to execute Rake tasks with Puppet Check. Please install Rake before continuing.'
end
require_relative '../puppet-check'

# the rake interface for PuppetCheck
class PuppetCheck::Tasks < ::Rake::TaskLib
  def initialize
    desc 'Execute all Puppet-Check checks'
    task puppetcheck: %w[puppetcheck:file puppetcheck:spec puppetcheck:beaker]

    namespace :puppetcheck do
      desc 'Execute Puppet-Check file checks'
      task :file do
        PuppetCheck.new.run(Dir.glob('*'))
      end

      begin
        require 'rspec/core/rake_task'
        require_relative 'rspec_puppet_support'

        desc 'Execute RSpec and RSpec-Puppet tests'
        RSpec::Core::RakeTask.new(:spec) do |task|
          RSpecPuppetSupport.run
          # generate tasks for all recognized directories and ensure spec tests inside module dependencies are ignored
          spec_dirs = Dir.glob('**/{classes,defines,facter,functions,hosts,puppet,unit,types}/**/*_spec.rb').reject { |dir| dir =~ /fixtures/ }
          task.pattern = spec_dirs.empty? ? 'skip_rspec' : spec_dirs
          task.rspec_opts = '-f json' if PuppetCheck.settings[:output_format] == 'json'
        end

        desc 'Execute Beaker acceptance tests'
        RSpec::Core::RakeTask.new(:beaker) do |task|
          # generate tasks for all recognized directories and ensure acceptance tests inside module dependencies are ignored
          acceptance_dirs = Dir.glob('**/acceptance').reject { |dir| dir =~ /fixtures/ }
          task.pattern = acceptance_dirs.empty? ? 'skip_beaker' : acceptance_dirs
          task.rspec_opts = '-f json' if PuppetCheck.settings[:output_format] == 'json'
        end
      rescue LoadError
        puts 'RSpec is not installed. The RSpec/RSpecPuppet and Beaker tasks will not be available.'
      end
    end
  end
end

PuppetCheck::Tasks.new
