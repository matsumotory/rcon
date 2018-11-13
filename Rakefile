require 'fileutils'

MRUBY_VERSION=ENV["MRUBY_VERSION"] || "c3188cac431225fda48718f309ad3d9318a6e44f"
file :mruby do
  cmd =  "git clone git://github.com/mruby/mruby.git"
  case MRUBY_VERSION
  when /\A[a-fA-F0-9]+\z/
    cmd << " && cd mruby"
    cmd << " && git fetch  && git checkout #{MRUBY_VERSION}"
  when /\A\d\.\d\.\d\z/
    cmd << " && cd mruby"
    cmd << " && git fetch --tags && git checkout $(git rev-parse #{MRUBY_VERSION})"
  when "master"
    # skip
  else
    fail "Invalid MRUBY_VERSION spec: #{MRUBY_VERSION}"
  end
  sh cmd
end

APP_NAME=ENV["APP_NAME"] || "rcon"
APP_ROOT=ENV["APP_ROOT"] || Dir.pwd
# avoid redefining constants in mruby Rakefile
mruby_root=File.expand_path(ENV["MRUBY_ROOT"] || "#{APP_ROOT}/mruby")
mruby_config=File.expand_path(ENV["MRUBY_CONFIG"] || "build_config.rb")
ENV['MRUBY_ROOT'] = mruby_root
ENV['MRUBY_CONFIG'] = mruby_config
Rake::Task[:mruby].invoke unless Dir.exist?(mruby_root)
Dir.chdir(mruby_root)
load "#{mruby_root}/Rakefile"

desc "compile binary"
task :compile => [:all] do

  MRuby.each_target do |target|
    `#{target.cc.command} --version`
    abort("Command #{target.cc.command} for #{target.name} is missing.") unless $?.success?
  end
  %W(#{mruby_root}/build/x86_64-pc-linux-gnu/bin/#{APP_NAME} #{mruby_root}/build/i686-pc-linux-gnu/#{APP_NAME}").each do |bin|
    sh "strip --strip-unneeded #{bin}" if File.exist?(bin)
  end
end

namespace :test do
  desc "run mruby & unit tests"
  # only build mtest for host
  task :mtest => :compile do
    # in order to get mruby/test/t/synatx.rb __FILE__ to pass,
    # we need to make sure the tests are built relative from mruby_root
    MRuby.each_target do |target|
      # only run unit tests here
      target.enable_bintest = true
      run_test if target.test_enabled?
    end
  end

  def clean_env(envs)
    old_env = {}
    envs.each do |key|
      old_env[key] = ENV[key]
      ENV[key] = nil
    end
    yield
    envs.each do |key|
      ENV[key] = old_env[key]
    end
  end

  desc "run integration tests"
  task :bintest => :compile do
    MRuby.each_target do |target|
      clean_env(%w(MRUBY_ROOT MRUBY_CONFIG)) do
        run_bintest if target.bintest_enabled?
      end
    end
  end
end

desc "run all tests"
Rake::Task['test'].clear
task :test => ["test:mtest", "test:bintest"]

desc "package"
task :package do
  require_relative 'mrblib/rcon/version'

  FileUtils.rm_rf "../pkg"
  FileUtils.mkdir_p "../pkg" unless File.exist? "pkg"

  %w[glibc-2.12 glibc-2.14].each do |dist|
    Rake::Task["clean"].execute
    # build linux_amd64
    sh "docker-compose build #{dist}"
    sh "docker-compose run #{dist}"

    %w[linux_amd64].each do |target|
      Dir.chdir "../mruby/build/#{target}/bin" do
        sh "zip #{APP_NAME}.zip #{APP_NAME}" unless File.exist? "#{APP_NAME}.zip"
        FileUtils.mv "#{APP_NAME}.zip", "../../../../pkg/#{APP_NAME}_#{Rconner::VERSION}_#{target}_#{dist}.zip"
      end
    end
  end
end

task :ghr do
  sh "go get -u github.com/tcnksm/ghr" if `type ghr`.empty?
end

desc "release"
task :release => [:ghr] do
  Dir.chdir(APP_ROOT)
  require_relative 'mrblib/rcon/version'
  sh "ghr -u matsumotory --replace v#{Rconner::VERSION} pkg/"
end

desc "cleanup"
task :clean do
  sh "rake deep_clean"
end

namespace :local do
  desc "show help"
  task :version do
    require_relative 'mrblib/mruby-cli/version'
    puts "mruby-cli #{MRubyCLI::Version::VERSION}"
  end
end

def is_in_a_docker_container?
  `grep -q docker /proc/self/cgroup`
  $?.success?
end

Rake.application.tasks.each do |task|
  next
  unless task.name.start_with?("local:")
    # Inspired by rake-hooks
    # https://github.com/guillermo/rake-hooks
    old_task = Rake.application.instance_variable_get('@tasks').delete(task.name)
    desc old_task.full_comment
    task old_task.name => old_task.prerequisites do
      abort("Not running in docker, you should type \"docker-compose run <task>\".")         unless is_in_a_docker_container?
      old_task.invoke
    end
  end
end
