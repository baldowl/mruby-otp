assert 'TOTP#at' do
  totp = TOTP.new 'ABCDEFGH'
  assert_equal '058591', totp.at(1)
  assert_equal '058591', totp.at(29)
  assert_equal '233946', totp.at(30)
  assert_equal '233946', totp.at(59)
  assert_equal 58591, totp.at(1, :padding => false)

  # With more digits
  totp = TOTP.new 'ABCDEFGH', :digits => 10
  assert_equal '1445058591', totp.at(1)
  assert_equal '1445058591', totp.at(29)
  assert_equal '0649233946', totp.at(30)
  assert_equal '0649233946', totp.at(59)
  assert_equal 649233946, totp.at(59, :padding => false)

  # With an unsupported digest
  totp = TOTP.new 'ABCDEFGH', :digest => 'unsupported'
  assert_raise(ArgumentError) { totp.at 1 }

  # With a different interval
  totp = TOTP.new 'ABCDEFGH', :interval => 60
  assert_equal '058591', totp.at(1)
  assert_equal '058591', totp.at(59)
  assert_equal '233946', totp.at(60)

  # With timestamps
  totp = TOTP.new 'ABCDEFGH'
  assert_equal '058591', totp.at(Time.gm(1970, 1, 1, 0, 0, 0))
  assert_equal '233946', totp.at(Time.gm(1970, 1, 1, 0, 0, 30))
end

assert 'TOTP#timestamp_to_count' do
  totp = TOTP.new 'ABCDEFGH'

  assert_equal 0, totp.send(:timestamp_to_count, 1)
  assert_equal 0, totp.send(:timestamp_to_count, 29)
  assert_equal 1, totp.send(:timestamp_to_count, 30)
  assert_equal 1, totp.send(:timestamp_to_count, 59)

  assert_equal 0, totp.send(:timestamp_to_count, Time.gm(1970, 1, 1, 0, 0, 0))
  assert_equal 1, totp.send(:timestamp_to_count, Time.gm(1970, 1, 1, 0, 0, 30))

  # With a different interval
  totp = TOTP.new 'ABCDEFGH', :interval => 60
  assert_equal 0, totp.send(:timestamp_to_count, 1)
  assert_equal 0, totp.send(:timestamp_to_count, 59)
  assert_equal 1, totp.send(:timestamp_to_count, 60)
end

assert 'TOTP#map_to_digest' do
  totp = TOTP.new 'ABCDEFGH'

  assert_raise(ArgumentError) { totp.send(:map_to_digest, 'garbage') }

  assert_nothing_raised { totp.send(:map_to_digest, 'sha1') }
  assert_equal Digest::SHA1, totp.send(:map_to_digest, 'sha1')

  assert_nothing_raised { totp.send(:map_to_digest, 'sha256') }
  assert_equal Digest::SHA256, totp.send(:map_to_digest, 'sha256')

  assert_nothing_raised { totp.send(:map_to_digest, 'sha512') }
  assert_equal Digest::SHA512, totp.send(:map_to_digest, 'sha512')
end

assert 'TOTP#current' do
  totp = TOTP.new 'ABCDEFGH'
  assert_equal totp.at(Time.now), totp.current
  assert_equal totp.at(Time.now, :padding => true), totp.current(:padding => true)
  assert_equal totp.at(Time.now, :padding => false), totp.current(:padding => false)
  assert_not_equal totp.at(Time.now.to_i - 1_000), totp.current
end

assert 'TOTP#verify' do
  totp = TOTP.new 'ABCDEFGH'

  # Slightly redundant
  assert_true totp.verify(totp.current)
  assert_true totp.verify(totp.current, :at => Time.now)
  assert_true totp.verify(totp.current(:padding => false), :at => Time.now, :padding => false)

  assert_true totp.verify('058591', :at => Time.gm(1970, 1, 1, 0, 0, 0))
  assert_true totp.verify(58591, :at => Time.gm(1970, 1, 1, 0, 0, 0), :padding => false)
  assert_true totp.verify('233946', :at => Time.gm(1970, 1, 1, 0, 0, 30))

  assert_false totp.verify(totp.at(Time.now - 31), :at => Time.now)
  assert_true totp.verify(totp.at(Time.now - 31), :at => Time.now, :drift => 60)
end

assert 'TOTP#uri' do
  test_vectors = [
    {
      :secret => 'ABCDEFGH',
      :digits => 6,
      :interval => 30,
      :digest => 'SHA1',
      :account => 'bob@example.com',
      :issuer => 'ExampleNet Inc'
    },
    {
      :secret => 'ABCDEFGH',
      :digits => 8,
      :interval => 30,
      :digest => 'SHA1',
      :account => 'bob@example.com',
      :issuer => 'ExampleNet Inc'
    },
    {
      :secret => 'ABCDEFGH',
      :digits => 6,
      :interval => 55,
      :digest => 'SHA1',
      :account => 'bob@example.com',
      :issuer => 'ExampleNet Inc'
    },
    {
      :secret => 'ABCDEFGH',
      :digits => 6,
      :interval => 30,
      :digest => 'SHA256',
      :account => 'bob@example.com',
      :issuer => 'ExampleNet Inc'
    },
    {
      :secret => 'ABCDEFGH',
      :digits => 6,
      :interval => 30,
      :digest => 'SHA512',
      :account => 'bob@example.com',
      :issuer => 'ExampleNet Inc'
    },
    {
      :secret => 'ABCDEFGH',
      :digits => 6,
      :interval => 30,
      :digest => 'SHA1',
      :account => 'bob@example.com'
    }
  ]
  test_vectors.each do |config|
    totp = TOTP.new config[:secret], :digits => config[:digits],
      :interval => config[:interval], :digest => config[:digest]

    # otpauth://TYPE/LABEL?PARAMETERS
    uri = totp.uri config[:account], :issuer => config[:issuer]

    protocol = uri.split('://').first
    type = uri.split('/')[2]
    label = uri.split('/')[3].split('?').first
    parameters = uri.split('?').last.split('&')

    assert_equal 'otpauth', protocol
    assert_equal 'totp', type

    # LABEL: accountname / issuer (":" / "%3A") *"%20" accountname
    if config[:issuer]
      assert_equal URI.encode("#{config[:issuer]}:#{config[:account]}"), label
    else
      assert_equal URI.encode(config[:account]), label
    end

    assert_equal "secret=#{config[:secret]}", parameters[0]
    assert_equal "algorithm=#{config[:digest]}", parameters[1]
    assert_equal "digits=#{config[:digits]}", parameters[2]
    assert_equal "period=#{config[:interval]}", parameters[3]

    if config[:issuer]
      # issuer (recommended; URL-encoded; if present must be equals to the issuer prefix of the label)
      assert_equal "issuer=#{URI.encode(config[:issuer])}", parameters[4]
      assert_equal label.split('%3A').first, parameters[4].split('=').last
    end
  end
end

assert 'RFC compatibility' do
  # As of today, 2017-08-06, RFC 6238's Appendix B is misleading: a different
  # shared secret string is used for each of the three HMAC functions. See
  # https://www.rfc-editor.org/errata_search.php?rfc=6238
  test_vectors = [
    {
      :digest => 'sha1',
      :secret => '12345678901234567890',
      :tokens => [
        [59,          '94287082'],
        [1111111109,  '07081804'],
        [1111111111,  '14050471'],
        [1234567890,  '89005924'],
        [2000000000,  '69279037'],
        [20000000000, '65353130']
      ]
    },
    {
      :digest => 'sha256',
      :secret => '12345678901234567890123456789012',
      :tokens => [
        [59,          '46119246'],
        [1111111109,  '68084774'],
        [1111111111,  '67062674'],
        [1234567890,  '91819424'],
        [2000000000,  '90698825'],
        [20000000000, '77737706']
      ]
    },
    {
      :digest => 'sha512',
      :secret => '1234567890123456789012345678901234567890123456789012345678901234',
      :tokens => [
        [59,          '90693936'],
        [1111111109,  '25091201'],
        [1111111111,  '99943326'],
        [1234567890,  '93441116'],
        [2000000000,  '38618901'],
        [20000000000, '47863826']
      ]
    }
  ]
  test_vectors.each do |config|
    totp = TOTP.new(Base32.encode(config[:secret]), :digest => config[:digest], :digits => 8)
    config[:tokens].each do |timestamp, token|
      assert_true totp.verify(token, :at => timestamp)
    end
  end
end
