require 'test_helper'

class Pay2goModuleTest < Test::Unit::TestCase
  include OffsitePayments::Integrations

  def test_notification_method
    assert_instance_of Pay2go::Notification, Pay2go.notification('name=cody')
  end
end
