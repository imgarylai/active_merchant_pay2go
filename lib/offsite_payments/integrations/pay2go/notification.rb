# encoding: utf-8
require 'digest'

module OffsitePayments #:nodoc:
  module Integrations #:nodoc:
    module Pay2go
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
