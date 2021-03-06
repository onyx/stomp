# -*- encoding: utf-8 -*-

$:.unshift(File.dirname(__FILE__))

require 'test_helper'

class TestConnection1P < Test::Unit::TestCase
  include TestBase
  
  def setup
    @conn = get_connection()
  end

  def teardown
    @conn.disconnect if @conn.open? # allow tests to disconnect
  end
  #
  def test_conn_1p_0000
    assert @conn.open?
  end
  #
  def test_conn_1p_0010
    #
    cha = {:host => "localhost"}
    assert_raise Stomp::Error::ProtocolErrorConnect do
      conn = Stomp::Connection.open(user, passcode, host, port, false, 5, cha)
    end    
    #
    chb = {"accept-version" => "1.0"}
    assert_raise Stomp::Error::ProtocolErrorConnect do
      conn = Stomp::Connection.open(user, passcode, host, port, false, 5, chb)
    end    
  end
  #
  def test_conn_1p_0020
    #
    cha = {:host => "localhost", "accept-version" => "1.0"}
    cha[:host] = "/" if ENV['STOMP_RABBIT']
    conn = nil
    assert_nothing_raised do
      conn = Stomp::Connection.open(user, passcode, host, port, false, 5, cha)
      conn.disconnect
    end
    assert_equal conn.protocol, Stomp::SPL_10
  end
  #
  def test_conn_1p_0030
    #
    cha = {:host => "localhost", "accept-version" => "1.1"}
    cha[:host] = "/" if ENV['STOMP_RABBIT']
    conn = nil
    assert_nothing_raised do
      conn = Stomp::Connection.open(user, passcode, host, port, false, 5, cha)
      conn.disconnect
    end
    assert_equal conn.protocol, Stomp::SPL_11
  end
  #
  def test_conn_1p_0040
    #
    cha = {:host => "localhost", "accept-version" => "1.1"}
    cha[:host] = "/" if ENV['STOMP_RABBIT']
    cha["heart-beat"] = "0,0" # No heartbeats
    conn = nil
    assert_nothing_raised do
      conn = Stomp::Connection.open(user, passcode, host, port, false, 5, cha)
      conn.disconnect
    end
    assert_equal conn.protocol, Stomp::SPL_11
  end
  #

  def test_conn_1p_0050
    #
    cha = {:host => "localhost", "accept-version" => "1.1"}
    cha[:host] = "/" if ENV['STOMP_RABBIT']
    cha["heart-beat"] = "10,10,20" # Bad header Heartbeats
    conn = nil
    assert_raise Stomp::Error::InvalidHeartBeatHeaderError do
      conn = Stomp::Connection.open(user, passcode, host, port, false, 5, cha)
    end
  end
  #
  def test_conn_11h_0060
    #
    cha = {:host => "localhost", "accept-version" => "1.1"}
    cha[:host] = "/" if ENV['STOMP_RABBIT']
    cha["heart-beat"] = "a,10" # Bad header Heartbeats
    conn = nil
    assert_raise Stomp::Error::InvalidHeartBeatHeaderError do
      conn = Stomp::Connection.open(user, passcode, host, port, false, 5, cha)
    end
  end
  #
  def test_conn_1p_0070
    #
    cha = {:host => "localhost", "accept-version" => "1.1"}
    cha[:host] = "/" if ENV['STOMP_RABBIT']
    cha["heart-beat"] = "500,1000" # Valid heart beat headers
    conn = nil
    assert_nothing_raised do
      conn = Stomp::Connection.open(user, passcode, host, port, false, 5, cha)
      conn.disconnect
    end
  end

  #
  def test_conn_1p_0080
    #
    cha = {:host => "localhost", "accept-version" => "1.1"}
    cha[:host] = "/" if ENV['STOMP_RABBIT']
    cha["heart-beat"] = "5000,0" # Valid heart beat headers, send only
    conn = nil
    assert_nothing_raised do
      conn = Stomp::Connection.open(user, passcode, host, port, false, 5, cha)
      sleep 65
      conn.disconnect
    end
  end if ENV['STOMP_HB11LONG']

  #
  def test_conn_1p_0090
    #
    cha = {:host => "localhost", "accept-version" => "1.1"}
    cha[:host] = "/" if ENV['STOMP_RABBIT']
    cha["heart-beat"] = "0,10000" # Valid heart beat headers, receive only
    conn = nil
    assert_nothing_raised do
      conn = Stomp::Connection.open(user, passcode, host, port, false, 5, cha)
#      m = conn.receive # This will hang forever .....
      sleep 65
      conn.disconnect
    end
  end if ENV['STOMP_HB11LONG']

  #
  def test_conn_1p_0100
    #
    cha = {:host => "localhost", "accept-version" => "1.1"}
    cha[:host] = "/" if ENV['STOMP_RABBIT']
    cha["heart-beat"] = "5000,10000" # Valid heart beat headers, send and receive
    conn = nil
    assert_nothing_raised do
      conn = Stomp::Connection.open(user, passcode, host, port, false, 5, cha)
#      m = conn.receive # This will hang forever .....
      sleep 65
      conn.disconnect
    end
  end if ENV['STOMP_HB11LONG']
  #
  def test_conn_1p_0110
    #
    cha = {:host => "localhost", "accept-version" => "1.1"}
    cha[:host] = "/" if ENV['STOMP_RABBIT']
    cha["heart-beat"] = "0,0" # No heartbeats
    conn = nil
    conn = Stomp::Connection.open(user, passcode, host, port, false, 5, cha)
    good_data = [
      "\x41\xc3\xb1\x42",
      "\xc2\x80", # 2 byte characters
      "\xc2\xbf",
      "\xdf\x80",
      "\xdf\xbf",
      "\xe0\xa0\x80", # 3 byte characters
      "\xe0\xbf\x80",
      "\xe0\xa0\xbf",
      "\xe0\xbf\xbf",
      "\xf1\x80\x80\x80", # 4 byte characters
      "\xf1\xbf\xbf\xbf",
      "\xf2\x80\x80\x80",
      "\xf2\xbf\xbf\xbf",
      "\xf3\x80\x80\x80",
      "\xf3\xbf\xbf\xbf",
    ]
    good_data.each do |string|
      assert conn.valid_utf8?(string), "good unicode specs 01: #{string}"
    end
    conn.disconnect
  end

  #
  def test_conn_1p_0120
    #
    cha = {:host => "localhost", "accept-version" => "1.1"}
    cha[:host] = "/" if ENV['STOMP_RABBIT']
    cha["heart-beat"] = "0,0" # No heartbeats
    conn = nil
    conn = Stomp::Connection.open(user, passcode, host, port, false, 5, cha)
    bad_data = [
      "\x41\xc2\xc3\xb1\x42",
      "\xed\xa0\x80", # UTF-16 surrogate halves
      "\xed\xad\xbf",
      "\xed\xae\x80",
      "\xed\xaf\xbf",
      "\xed\xb0\x80",
      "\xed\xbe\x80",
      "\xed\xbf\xbf",
      "\xc0", # Single bytes
      "\xc1",
      "\xf5","\xf6","\xf7","\xf8","\xf9","\xfa","\xfb","\xfc",
      "\xfd","\xfe","\xff",
      "\xc0\x80", # Not shortest representation
      "\xc1\x80",
      "\xc0\x30",
      "\xc1\x30",
      "\xe0\x80\x80",
      "\xf0\x80\x80\x80",
    ]
    bad_data.each do |string|
      assert !conn.valid_utf8?(string), "bad unicode specs 01: #{string}"
    end
    conn.disconnect
  end

  # Repeated headers test. Currently:
  # - Apollo emits repeated headers for a 1.1 connection only
  # - RabbitMQ does not emit repeated headers under any circumstances
  def test_conn_1p_0120
    dest = make_destination
    msg = "payload: #{Time.now.to_f}"
    shdrs = { "key1" => "val1", "key2" => "val2",
      "key3" => ["kv3", "kv2", "kv1"] }
    assert_nothing_raised {
      @conn.publish dest, msg, shdrs
    }
    #
    sid = @conn.uuid()
    @conn.subscribe dest, :id => sid
    #
    received = @conn.receive
    assert_equal msg, received.body
    if @conn.protocol != Stomp::SPL_10
      assert_equal shdrs["key3"], received.headers["key3"] unless ENV['STOMP_RABBIT']
    else
      assert_equal "kv3", received.headers["key3"]
    end
    #
    @conn.unsubscribe dest, :id => sid
  end

end if ENV['STOMP_TEST11']

