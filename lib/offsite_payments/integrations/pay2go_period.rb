# encoding: utf-8
require 'digest'

module OffsitePayments #:nodoc:
  module Integrations #:nodoc:
    module Pay2goPeriod

      VERSION = '1.0'
      RESPOND_TYPE = 'String'
      CHECK_VALUE_FIELDS = %w(PeriodAmt MerchantID MerchantOrderNo TimeStamp PeriodType)
      CHECK_CODE_FIELDS = %w(PeriodType MerchantID MerchantOrderNo)

      mattr_accessor :service_url
      mattr_accessor :merchant_id
      mattr_accessor :hash_key
      mattr_accessor :hash_iv
      mattr_accessor :debug

      def self.service_url
        mode = ActiveMerchant::Billing::Base.mode
        case mode
          when :production
            'https://api.pay2go.com/API/PeriodAPI'
          when :development
            'https://capi.pay2go.com/API/PeriodAPI'
          when :test
            'https://capi.pay2go.com/API/PeriodAPI'
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

      class Helper < OffsitePayments::Helper
        FIELDS = %w(
          MerchantID MerchantOrderNo PeriodAmt ProdDesc PeriodAmtMode PeriodType PeriodPoint PeriodStartType
          PeriodTimes ReturnURL ProDetail PeriodMemo PaymentInfo OrderInfo InvoiceInfo NotifyURL
        )

        FIELDS.each do |field|
          mapping field.underscore.to_sym, field
        end
        mapping :account, 'MerchantID' # AM common

        def initialize(order, account, options = {})
          super
          add_field 'MerchantID', OffsitePayments::Integrations::Pay2go.merchant_id
          add_field 'Version', OffsitePayments::Integrations::Pay2goPeriod::VERSION
          add_field 'RespondType', OffsitePayments::Integrations::Pay2goPeriod::RESPOND_TYPE
        end

        def time_stamp(date)
          add_field 'TimeStamp', date.to_time.to_i
        end

        def encrypted_data
          raw_data = URI.encode_www_form OffsitePayments::Integrations::Pay2goPeriod::CHECK_VALUE_FIELDS.sort.map { |field|
            [field, @fields[field]]
          }

          hash_raw_data = "HashKey=#{OffsitePayments::Integrations::Pay2go.hash_key}&#{raw_data}&HashIV=#{OffsitePayments::Integrations::Pay2go.hash_iv}"
          add_field 'CheckValue', Digest::SHA256.hexdigest(hash_raw_data).upcase
        end

      end

      class Notification < OffsitePayments::Notification
        PARAMS_FIELDS = %w(
          Status Message MerchantID MerchantOrderNo PeriodType authDate authTime dateArray PeriodTotalAmt
          PeriodFirstAmt PeriodAmt CheckCode
        )

        PARAMS_FIELDS.each do |field|
          define_method field.underscore do
            @params[field]
          end
        end

        def success?
          status == 'SUCCESS'
        end

        # TODO 使用查詢功能實作 acknowledge
        # Pay2go 沒有遠端驗證功能，
        # 而以 checksum_ok? 代替
        def acknowledge
          checksum_ok?
        end

        def complete?
          %w(SUCCESS CUSTOM).include? status
        end

        def checksum_ok?
          raw_data = URI.encode_www_form OffsitePayments::Integrations::Pay2goPeriod::CHECK_CODE_FIELDS.sort.map { |field|
            [field, @params[field]]
          }

          hash_raw_data = "HashIV=#{OffsitePayments::Integrations::Pay2go.hash_iv}&#{raw_data}&HashKey=#{OffsitePayments::Integrations::Pay2go.hash_key}"
          Digest::SHA256.hexdigest(hash_raw_data).upcase == check_code
        end
      end
    end
  end
end
