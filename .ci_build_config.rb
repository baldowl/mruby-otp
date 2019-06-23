MRuby::Build.new do |conf|
  toolchain :gcc
  conf.enable_debug
  conf.gembox 'default'
  conf.gem '.'
  conf.enable_test
end
