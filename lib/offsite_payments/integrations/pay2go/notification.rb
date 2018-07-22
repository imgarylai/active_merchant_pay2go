# encoding: utf-8
require 'digest'

module OffsitePayments #:nodoc:
  module Integrations #:nodoc:
    module Pay2go
      class Notification < OffsitePayments::Notification
        PARAMS_FIELDS = %w(
          Status Message MerchantID Amt TradeNo MerchantOrderNo PaymentType RespondType CheckCode PayTime IP
          EscrowBank TokenUseStatus RedAmt RespondCode Auth Card6No Card4No Inst InstFirst InstEach ECI PayBankCode
          PayerAccount5Code CodeNo BankCode Barcode_1 Barcode_2 Barcode_3 ExpireDate ExpireTime Version TradeInfo TradeSha
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
          key = OffsitePayments::Integrations::Pay2go.hash_key
          iv = OffsitePayments::Integrations::Pay2go.hash_iv

          aes = OpenSSL::Cipher.new('AES-256-CBC')
          aes.encrypt
          aes.key = key
          aes.iv = iv

          raw_data = URI.encode_www_form OffsitePayments::Integrations::Pay2go::CHECK_CODE_FIELDS.map { |field|
            [field, @params[field]]
          }

          trade_info = (aes.update(raw_data) + aes.final).unpack('H*').first
          Digest::SHA256.hexdigest("HashKey=#{key}&#{trade_info}&HashIV=#{iv}").upcase == trade_sha
        end
      end
    end
  end
end
