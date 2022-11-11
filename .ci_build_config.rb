MRuby::Build.new do |conf|
  conf.toolchain
  conf.enable_debug
  conf.gembox 'default'
  conf.gem '.'
  conf.enable_test

  # Because some algorithms have been moved to OpenSSL's legacy provider and
  # mruby-digest is not ready for this.
  conf.cc do | cc|
    cc.defines << %w(OPENSSL_NO_RIPEMD OPENSSL_NO_RIPEMD160 OPENSSL_NO_RMD160)
  end
end
