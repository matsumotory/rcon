def gem_config(conf)
  conf.gembox 'full-core'
  conf.gem :mgem => "mruby-rcon"
  conf.gem :mgem => "mruby-env"
  conf.gem :mgem => "mruby-getopts"
  conf.gem :mgem => "mruby-signal"

  # be sure to include this gem (the cli app)
  conf.gem File.expand_path(File.dirname(__FILE__))
end

MRuby::Build.new do |conf|
  toolchain :gcc

  conf.enable_bintest
  conf.enable_debug
  conf.enable_test

  gem_config(conf)
end
