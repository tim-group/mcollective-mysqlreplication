require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'

desc "Run specs"
RSpec::Core::RakeTask.new

desc "Run lint (Rubocop)"
task :lint do
  sh 'rubocop agent application spec'
end

# rubocop:disable ParameterLists
def package(build_dir, root_dir, files, name, version, depends)
  sh "mkdir -p #{build_dir}/#{root_dir}"
  sh "cp #{files} #{build_dir}/#{root_dir}"
  args = [
    "-s", "dir",
    "-t", "deb",
    "--architecture", "all",
    "-C", "#{build_dir}",
    "--name", "mcollective-appconfig-#{name}",
    "--version", "#{version}",
    "--prefix", "/usr/share/mcollective/plugins/mcollective/",
    depends.map { |dep| "-d #{dep} " }.join
  ].join(" ")

  sh "fpm #{args}"
end

desc "Create a debian package"
task :package => [:clean] do
  sh "mkdir -p build"
  hash = %x(git rev-parse --short HEAD).chomp
  v_part = ENV['BUILD_NUMBER'] || "0.pre.#{hash}"
  version = "0.0.#{v_part}"

  package("build/common", "agent", "agent/appconfig.ddl", "common", version, [])
  package("build/agent", "agent", "agent/appconfig.rb", "agent", version,
          ["mcollective-appconfig-common"])
  package("build/application", "application", "application/appconfig.rb",
          "application", version, ["mcollective-appconfig-common"])
end

desc "Create and install debian package"
task :install => [:package] do
  sh "sudo dpkg -i *common*.deb"
  sh "sudo dpkg -i *agent*.deb"
  sh "sudo dpkg -i *application*.deb"
  sh "sudo /etc/init.d/mcollective restart;"
end

desc "Clean artifacts created by this build"
task :clean do
  sh "rm -rf build"
  sh "rm  -f *deb"
end

task :default => %w(lint)
