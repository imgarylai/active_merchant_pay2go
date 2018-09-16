# encoding: utf-8
require 'digest'

module OffsitePayments #:nodoc:
  module Integrations #:nodoc:
    module Pay2go
      class Notification < OffsitePayments::Notification
        PARAMS_FIELDS = %w(
          Status MerchantID TradeInfo TradeSha Version
        )

        PARAMS_FIELDS.each do |field|
          define_method field.underscore do
            @params[field]
          end
        end

        # Overrides above define_method
        def trade_info
          key = OffsitePayments::Integrations::Pay2go.hash_key
          iv = OffsitePayments::Integrations::Pay2go.hash_iv

          aes = OpenSSL::Cipher.new('AES-256-CBC')
          aes.decrypt
          aes.padding = 0
          aes.key = key
          aes.iv = iv

          raw_data = aes.update([@params['TradeInfo']].pack('H*')) + aes.final
          URI.decode_www_form(raw_data).to_h
        end

        TRADE_INFO_FIELDS = %w(
          Message Amt TradeNo MerchantOrderNo PaymentType RespondType CheckCode PayTime IP
          EscrowBank TokenUseStatus RedAmt RespondCode Auth Card6No Card4No Inst InstFirst InstEach ECI PayBankCode
          PayerAccount5Code CodeNo BankCode Barcode_1 Barcode_2 Barcode_3 ExpireDate ExpireTime
        )

        TRADE_INFO_FIELDS.each do |field|
          define_method field.underscore do
            trade_info[field]
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

          Digest::SHA256.hexdigest("HashKey=#{key}&#{@params['TradeInfo']}&HashIV=#{iv}").upcase == trade_sha
        end
      end
    end
  end
end
