require 'test_helper'

class Pay2goHelperTest < Minitest::Test
  include OffsitePayments::Integrations

  def setup
  end

  def test_check_value
    @helper = Pay2go::Helper.new 'sdfasdfa', '123456'
    @helper.add_field 'Amt', '200'
    @helper.add_field 'MerchantID', '123456'
    @helper.add_field 'MerchantOrderNo','20140901001'
    @helper.add_field 'TimeStamp', '1403243286'
    @helper.add_field 'Version', '1.2'

    OffsitePayments::Integrations::Pay2go.hash_key = 'GADlNOKdHiTBjdgW6uAjngF9ItT6nCW4'
    OffsitePayments::Integrations::Pay2go.hash_iv = 'dzq1naf5t8HMmXIs'

    @helper.encrypted_data
    # HashKey=GADlNOKdHiTBjdgW6uAjngF9ItT6nCW4&Amt=200&MerchantID=123456&MerchantOrderNo=20140901001&TimeStamp=1403243286&Version=1.2&HashIV=dzq1naf5t8HMmXIs
    assert_equal '6D68350DBA6CD9A0891129FF8C4070505509826D79104E95F9C815A8DD6B211B', @helper.fields['CheckValue']
  end

end
