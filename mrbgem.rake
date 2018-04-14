MRuby::Gem::Specification.new 'mruby-otp' do |spec|
  spec.license  = 'MIT'
  spec.author   = 'Emanuele Vicentini'
  spec.summary  = 'Generate and verify OTPs (HOTP and TOTP)'
  spec.homepage = 'https://github.com/baldowl/mruby-otp'

  spec.add_dependency 'mruby-base32', :github => 'qtkmz/mruby-base32'
  spec.add_dependency 'mruby-digest', :github => 'iij/mruby-digest'
  spec.add_dependency 'mruby-time'
  spec.add_dependency 'mruby-secure-compare', :github => 'Asmod4n/mruby-secure-compare'
  spec.add_dependency 'mruby-uri-parser', :github => 'Asmod4n/mruby-uri-parser'
end
