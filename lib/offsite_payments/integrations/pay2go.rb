# encoding: utf-8
require 'digest'

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
            'https://api.pay2go.com/MPG/mpg_gateway'
          when :development
            'https://capi.pay2go.com/MPG/mpg_gateway'
          when :test
            'https://capi.pay2go.com/MPG/mpg_gateway'
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
          MerchantID LangType MerchantOrderNo Amt ItemDesc TradeLimit ExpireDate ReturnURL NotifyURL CustomerURL ClientBackURL Email EmailModify LoginType OrderComment CREDIT CreditRed InstFlag UNIONPAY WEBATM VACC CVS BARCODE CUSTOM TokenTerm
        )

        FIELDS.each do |field|
          mapping field.underscore.to_sym, field
        end
        mapping :account, 'MerchantID' # AM common
        mapping :amount, 'Amt' # AM common

        def initialize(order, account, options = {})
          super
          add_field 'Version', OffsitePayments::Integrations::Pay2go::VERSION
          add_field 'RespondType', OffsitePayments::Integrations::Pay2go::RESPOND_TYPE
          OffsitePayments::Integrations::Pay2go::CONFIG.each do |field|
            add_field field, OffsitePayments::Integrations::Pay2go.send(field.underscore.to_sym)
          end
        end

        def time_stamp(date)
          add_field 'TimeStamp', date.to_time.to_i
        end

        def encrypted_data
          raw_data = URI.encode_www_form OffsitePayments::Integrations::Pay2go::CHECK_VALUE_FIELDS.sort.map { |field|
            [field, @fields[field]]
          }

          hash_raw_data = "HashKey=#{OffsitePayments::Integrations::Pay2go.hash_key}&#{raw_data}&HashIV=#{OffsitePayments::Integrations::Pay2go.hash_iv}"
          add_field 'CheckValue', Digest::SHA256.hexdigest(hash_raw_data).upcase
        end
      end

      class Notification < OffsitePayments::Notification
        PARAMS_FIELDS = %w(
          Status Message MerchantID Amt TradeNo MerchantOrderNo PaymentType RespondType CheckCode PayTime IP
          EscrowBank TokenUseStatus RespondCode Auth Card6No Card4No Inst InstFirst InstEach ECI PayBankCode
          PayerAccount5Code CodeNo BankCode Barcode_1 Barcode_2 Barcode_3 ExpireDate CheckCode
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
          raw_data = URI.encode_www_form OffsitePayments::Integrations::Pay2go::CHECK_CODE_FIELDS.sort.map { |field|
            [field, @params[field]]
          }

          hash_raw_data = "HashIV=#{OffsitePayments::Integrations::Pay2go.hash_iv}&#{raw_data}&HashKey=#{OffsitePayments::Integrations::Pay2go.hash_key}"
          Digest::SHA256.hexdigest(hash_raw_data).upcase == check_code
        end
      end
    end
  end
end
