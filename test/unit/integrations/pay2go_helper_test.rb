# encoding: utf-8
require 'test_helper'

class Pay2goHelperTest < Test::Unit::TestCase
  include OffsitePayments::Integrations

  def setup
  end

  def test_check_value
    @helper = Pay2go::Helper.new 'sdfasdfa', '123456'
    @helper.add_field 'Amt', '200'
    @helper.add_field 'MerchantID', '123456'
    @helper.add_field 'MerchantTradeNo','20140901001'
    @helper.add_field 'TimeStamp', '1403243286'
    @helper.add_field 'Version', '1.2'

    OffsitePayments::Integrations::Pay2go.hash_key = 'GADlNOKdHiTBjdgW6uAjngF9ItT6nCW4'
    OffsitePayments::Integrations::Pay2go.hash_iv = 'dzq1naf5t8HMmXIs'

    @helper.encrypted_data

    assert_equal '708980B376BAED99F43064B8AF54D23090457B51DFEEF138A29387F12276FD47', @helper.fields['CheckValue']
  end

end
