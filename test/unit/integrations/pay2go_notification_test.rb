require 'test_helper'

class Pay2goNotificationTest < Test::Unit::TestCase
  include OffsitePayments::Integrations

  def setup
    OffsitePayments::Integrations::Pay2go.hash_key = 'GADlNOKdHiTBjdgW6uAjngF9ItT6nCW4'
    OffsitePayments::Integrations::Pay2go.hash_iv = 'dzq1naf5t8HMmXIs'
    @pay2go = Pay2go::Notification.new(http_raw_data)
  end

  def test_params
    p = @pay2go.params

    assert_equal 12, p.size
    assert_equal 'WEBATM', p['PaymentType']
    assert_equal '3EEDE1A325B553F4A728FAB12AC5C41F3DF778D15B5D23B04144763FF609036B', p['CheckCode']
    assert_equal '2014-07-31 09:44:04', p['PayTime']
  end

  def test_complete?
    assert @pay2go.complete?
  end

  def test_checksum_ok?
    assert @pay2go.checksum_ok?

    # Should preserve mac value
    assert @pay2go.params['CheckCode'].present?
  end

  private

  def http_raw_data
    # Sample notification from test environment
    "Status=SUCCESS&Message=%E4%BB%98%E6%AC%BE%E6%88%90%E5%8A%9F&MerchantID=3430112&Amt=30&TradeNo=14073109440419780&MerchantOrderNo=201407310943544334&RespondType=String&CheckCode=3EEDE1A325B553F4A728FAB12AC5C41F3DF778D15B5D23B04144763FF609036B&PaymentType=WEBATM&PayTime=2014-07-31+09%3A44%3A04&PayerAccount5Code=12345&PayBankCode=80800000"
  end
end
