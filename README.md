# mruby-otp [![Build Status](https://travis-ci.org/baldowl/mruby-otp.svg?branch=master)](https://travis-ci.org/baldowl/mruby-otp) [![GitHub version](https://badge.fury.io/gh/baldowl%2Fmruby-otp.svg)](https://badge.fury.io/gh/baldowl%2Fmruby-otp)

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
 => #<HOTP:0x7f8f23025fe8 @secret="12345678901234567890", @digits=6, @digest="sha1">
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
```

```ruby
> totp = TOTP.new(Base32.encode('12345678901234567890'))
 => #<TOTP:0x7f9dd1825fe8 @secret="12345678901234567890", @digits=6, @digest="sha1", @interval=30>
> p totp.at(Time.now)
"870674"
 => "870674"
> p totp.current
"870674"
 => "870674"
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
```

## License

This code is released under the MIT License: see LICENSE file.
