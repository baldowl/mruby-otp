# A simple implementation of RFC 4226.
#
#    hotp = HOTP.new(Base32.encode('12345678901234567890'))
#    otp = hotp.at(123)
#    hotp.verify(otp, :at => 133)
class HOTP
  # Default length of the generated OTPs.
  DEFAULT_DIGITS = 6

  ##
  # call-seq:
  #    HOTP.new(string)                    -> obj
  #    HOTP.new(string, :digits => int)    -> obj
  #
  # Returns the OTP generator object.
  #
  # +secret+ must be a base32 encoded string.
  #
  # Optional <tt>:digits</tt> controls the length of the OTPs generated by
  # this object.
  def initialize secret, options = {}
    @secret = Base32.decode secret
    @digits = options[:digits] || DEFAULT_DIGITS
    @digest = 'sha1'
  end

  ##
  # call-seq:
  #    otp_generator.at(int)                         -> obj
  #    otp_generator.at(int, :padding => boolean)    -> obj
  #
  # Calculates the OTP for +count+.
  #
  # The generated OTPs are normally padded with "0" if they are shorter than
  # the required length; this behavior can be controlled with
  # <tt>:padding</tt> (default value: +true+).
  def at count, options = {}
    opts = {:padding => true}.merge(options)
    hmac = Digest::HMAC.digest(count_to_bytestring(count), @secret, map_to_digest(@digest))
    offset = hmac[-1].ord & 0xF
    code = (hmac[offset].ord & 0x7F) << 24 |
      (hmac[offset + 1].ord & 0xFF) << 16 |
      (hmac[offset + 2].ord & 0xFF) << 8 |
      (hmac[offset + 3].ord & 0xFF)
    if opts[:padding]
      (code % 10 ** @digits).to_s.rjust(@digits, '0')
    else
      code % 10 ** @digits
    end
  end

  ##
  # call-seq:
  #    otp_generator.verify(string)                                     -> obj
  #    otp_generator.verify(string, :at => int, :padding => boolean)    -> obj
  #
  # Compare <tt>input_token</tt>, submitted by the user, with the OTP
  # generated for <tt>:at</tt> (default value: +0+); both the submitted token
  # and the calculated one can be zero-padded or not, depending on the value
  # of <tt>:padding</tt> (default value: +true+)
  def verify input_token, options = {}
    opts = {:at => 0, :padding => true}.merge(options)
    self.at(opts[:at], :padding => opts[:padding]).to_s.securecmp(input_token.to_s)
  end

  private

  def count_to_bytestring value, padding = 8
    v = value.abs
    bs = []
    until v == 0
      bs << (v & 0xFF).chr
      v >>= 8
    end
    bs.reverse.join.rjust(padding, 0.chr)
  end

  def map_to_digest digest_name
    case digest_name
    when 'sha1', 'SHA1'
      Digest::SHA1
    else
      raise ArgumentError, 'invalid digest'
    end
  end
end
