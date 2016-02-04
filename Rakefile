require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'

desc 'Run specs'
RSpec::Core::RakeTask.new

desc 'Run lint (Rubocop)'
task :lint do
  sh 'rubocop agent application spec'
end

# rubocop:disable ParameterLists
def package(build_dir, root_dir, files, name, version, depends)
  sh "mkdir -p #{build_dir}/#{root_dir}"
  sh "cp #{files} #{build_dir}/#{root_dir}"
  args = [
    '-s', 'dir',
    '-t', 'deb',
    '--architecture', 'all',
    '-C', "#{build_dir}",
    '--name', "mcollective-mysqlreplication-#{name}",
    '--maintainer', 'infra@timgroup.com',
    '--version', "#{version}",
    '--prefix', '/usr/share/mcollective/plugins/mcollective/',
    '--url', 'https://github.com/tim-group/mcollective-mysqlreplication',
    depends.map { |dep| "-d #{dep} " }.join
  ]
  args.concat ['--post-install', 'postinst.sh'] if root_dir == 'agent'
  sh "fpm #{args.join(' ')}"
end

desc 'Create a debian package'
task :package => [:clean] do
  sh 'mkdir -p build'
  hash = `git rev-parse --short HEAD`.chomp
  v_part = ENV['BUILD_NUMBER'] || "0.pre.#{hash}"
  version = "0.0.#{v_part}"
  dependancies = ['mcollective-mysqlreplication-common']

  package('build/common', 'agent', 'agent/mysqlreplication.ddl', 'common', version, [])
  package('build/agent', 'agent', 'agent/mysqlreplication.rb', 'agent', version, dependancies)
  package('build/application', 'application', 'application/mysqlreplication.rb', 'application', version, dependancies)
end

desc 'Create and install debian package'
task :install => [:package] do
  sh 'sudo dpkg -i *common*.deb'
  sh 'sudo dpkg -i *agent*.deb'
  sh 'sudo dpkg -i *application*.deb'
  sh 'sudo /etc/init.d/mcollective restart;'
end

desc 'Clean artifacts created by this build'
task :clean do
  sh 'rm -rf build'
  sh 'rm  -f *deb'
end

task :default => %w(lint)
