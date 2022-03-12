# mruby-otp [![CircleCI](https://circleci.com/gh/baldowl/mruby-otp.svg?style=svg)](https://circleci.com/gh/baldowl/mruby-otp) [![Actions Status: CI](https://github.com/baldowl/mruby-otp/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/baldowl/mruby-otp/actions?query=workflow%3ACI+branch%3Amaster) [![GitHub version](https://badge.fury.io/gh/baldowl%2Fmruby-otp.svg)](https://badge.fury.io/gh/baldowl%2Fmruby-otp)

A library to generate and verify OTPs (HOTP & TOTP) according to [RFC
4226](http://tools.ietf.org/html/rfc4226) and [RFC
6238](http://tools.ietf.org/html/rfc6238).

## Installation

Add the usual `conf.gem` line to `build_config.rb`:

```ruby
MRuby::Build.new do |conf|
  # ...

  conf.gem :github => 'baldowl/mruby-otp'
end
```

## Examples

```ruby
> hotp = HOTP.new(Base32.encode('12345678901234567890'))
 => #<HOTP:0x7fa74a0049b0 @digits=6, @digest="sha1", @type="hotp", @secret="12345678901234567890">
> p hotp.at(0)
"755224"
 => "755224"
> p hotp.at(1)
"287082"
 => "287082"
> p hotp.verify("755224")
true
 => true
> p hotp.verify("287082", :at => 1)
true
 => true
> p hotp.verify("287082", :at => 2)
false
 => false
> p hotp.uri("J. Doe", :issuer => "ExampleNet Inc")
"otpauth://hotp/ExampleNet%20Inc%3AJ.%20Doe?secret=GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ&algorithm=SHA1&digits=6&counter=&issuer=ExampleNet%20Inc"
 => "otpauth://hotp/ExampleNet%20Inc%3AJ.%20Doe?secret=GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ&algorithm=SHA1&digits=6&counter=&issuer=ExampleNet%20Inc"
```

```ruby
> totp = TOTP.new(Base32.encode('12345678901234567890'))
 => #<TOTP:0x7fa38681cfb0 @digits=6, @digest="sha1", @type="totp", @interval=30, @secret="12345678901234567890">
> p totp.at(Time.now)
"829461"
 => "829461"
> p totp.current
"829461"
 => "829461"
> t = Time.gm(1997, 8, 29, 5, 14, 00)
 => Fri Aug 29 05:14:00 UTC 1997
> p totp.at(t)
"281836"
 => "281836"
> p totp.verify(281836, :at => t)
true
 => true
> t2 = Time.gm(1997, 8, 29, 5, 14, 45)
 => Fri Aug 29 05:14:45 UTC 1997
> p totp.verify(281836, :at => t2)
false
 => false
> p totp.verify(281836, :at => t2, :drift => 25)
true
 => true
> p totp.uri("J. Doe", :issuer => "ExampleNet Inc")
"otpauth://totp/ExampleNet%20Inc%3AJ.%20Doe?secret=GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ&algorithm=SHA1&digits=6&period=30&issuer=ExampleNet%20Inc"
 => "otpauth://totp/ExampleNet%20Inc%3AJ.%20Doe?secret=GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ&algorithm=SHA1&digits=6&period=30&issuer=ExampleNet%20Inc"
> 
```

## License

This code is released under the MIT License: see LICENSE file.
