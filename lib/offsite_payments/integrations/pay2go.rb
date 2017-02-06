# encoding: utf-8
require 'digest'
require File.dirname(__FILE__) + '/pay2go/helper.rb'
require File.dirname(__FILE__) + '/pay2go/notification.rb'

module OffsitePayments #:nodoc:
  module Integrations #:nodoc:
    module Pay2go

      VERSION = '1.2'
      RESPOND_TYPE = 'String'
      CHECK_VALUE_FIELDS = %w(Amt MerchantID MerchantOrderNo TimeStamp Version)
      CHECK_CODE_FIELDS = %w(Amt MerchantID MerchantOrderNo TradeNo)

      CONFIG = %w(
        MerchantID LangType TradeLimit ExpireDate NotifyURL EmailModify LoginType
      )

      mattr_accessor :service_url
      mattr_accessor :hash_key
      mattr_accessor :hash_iv
      mattr_accessor :debug

      CONFIG.each do |field|
        mattr_accessor field.underscore.to_sym
      end

      def self.service_url
        mode = ActiveMerchant::Billing::Base.mode
        case mode
          when :production
            'https://core.spgateway.com/MPG/mpg_gateway'
          when :development
            'https://ccore.spgateway.com/MPG/mpg_gateway'
          when :test
            'https://ccore.spgateway.com/MPG/mpg_gateway'
          else
            raise StandardError, "Integration mode set to an invalid value: #{mode}"
        end
      end

      def self.notification(post)
        Notification.new(post)
      end

      def self.setup
        yield(self)
      end

    end
  end
end
