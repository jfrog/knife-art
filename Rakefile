require "rubygems"
require "rubygems/package_task"
require "rdoc/task"

GEM_NAME = "knife-artifactory".freeze

spec = eval(File.read("#{GEM_NAME}.gemspec"))

Gem::PackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

task install: :package do
  sh %{gem install pkg/#{GEM_NAME}-#{KnifeArt::VERSION} --no-rdoc --no-ri}
end

task :uninstall do
  sh %{gem uninstall #{GEM_NAME} -x -v #{KnifeArt::VERSION} }
end

begin
  require "chefstyle"
  require "rubocop/rake_task"
  RuboCop::RakeTask.new(:style) do |task|
    task.options << "--display-cop-names"
  end
rescue LoadError
  STDERR.puts "\n*** chefstyle not available. (sudo) gem install chefstyle to run unit tests. ***\n\n"
end

task default: [:style]
