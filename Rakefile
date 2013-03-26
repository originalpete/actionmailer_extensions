require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "actionmailer_extensions"
    gem.summary = %Q{Handy "save to disk" and "safe recipients" features for ActionMailer}
    gem.description = %Q{Wraps the deliver! method on ActionMailer to save the outgoing mail to a .eml file, 
      which can be opened by most email clients. Also provides a mechanism for only sending to an approved list of
      email recipients, which is useful for ensuring your application doesn't send email outside of an organization.}
    gem.email = "originalpete@gmail.com"
    gem.homepage = "http://github.com/originalpete/actionmailer_extensions"
    gem.authors = ["Peter MacRobert"]
    
    gem.add_dependency "actionmailer", "~> 2.3.10"
    
    gem.add_development_dependency "yard", ">= 0"
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_development_dependency "rr", ">= 0.10.5"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rspec/core'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
