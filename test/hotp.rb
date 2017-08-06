assert 'HOTP#at' do
  hotp = HOTP.new 'ABCDEFGH'
  assert_equal '233946', hotp.at(1)
  assert_equal '040032', hotp.at(19)
  assert_equal 40032, hotp.at(19, :padding => false)

  # With more digits
  hotp = HOTP.new 'ABCDEFGH', :digits => 10
  assert_equal '0649233946', hotp.at(1)
  assert_equal '0386040032', hotp.at(19)
  assert_equal 386040032, hotp.at(19, :padding => false)
end

assert 'HOTP#count_to_bytestring' do
  hotp = HOTP.new 'ABCDEFGH'

  # With default padding
  assert_equal "\000\000\000\000\000\000\000\001", hotp.send(:count_to_bytestring, 1)
  assert_equal "\000\000\000\000\000\000\000{", hotp.send(:count_to_bytestring, 123)
  assert_equal "\r\340\266\263\247d\000\000", hotp.send(:count_to_bytestring, 1_000_000_000_000_000_000)

  # With custom padding
  assert_equal "\000\001", hotp.send(:count_to_bytestring, 1, 2)
  assert_equal "\000{", hotp.send(:count_to_bytestring, 123, 2)
  assert_equal "\000\r\340\266\263\247d\000\000", hotp.send(:count_to_bytestring, 1_000_000_000_000_000_000, 9)

  # Let's take care of negative values
  assert_equal "\000\000\000\000\000\000\000\001", hotp.send(:count_to_bytestring, -1)
  assert_equal "\000\000\000\000\000\000\000{", hotp.send(:count_to_bytestring, -123)
  assert_equal "\r\340\266\263\247d\000\000", hotp.send(:count_to_bytestring, -1_000_000_000_000_000_000)
end

assert 'HOTP#map_to_digest' do
  hotp = HOTP.new 'ABCDEFGH'

  assert_raise(ArgumentError) { hotp.send(:map_to_digest, 'garbage') }

  assert_nothing_raised { hotp.send(:map_to_digest, 'sha1') }
  assert_equal Digest::SHA1, hotp.send(:map_to_digest, 'sha1')
end

assert 'HOTP#verify' do
  hotp = HOTP.new 'ABCDEFGH'

  assert_true hotp.verify('233946', :at => 1)
  assert_true hotp.verify('040032', :at => 19)
  assert_true hotp.verify(40032, :at => 19, :padding => false)
end

assert 'RFC compatibility' do
  hotp = HOTP.new(Base32.encode('12345678901234567890'))
  tokens = ['755224', '287082', '359152', '969429', '338314', '254676',
    '287922', '162583', '399871', '520489']

  tokens.each_with_index do |token, position|
    assert_equal token, hotp.at(position)
    assert_true hotp.verify(token, :at => position)
  end
end
