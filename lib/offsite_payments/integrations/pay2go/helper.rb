# encoding: utf-8
require 'openssl'
require 'digest'

module OffsitePayments #:nodoc:
  module Integrations #:nodoc:
    module Pay2go
      class Helper < OffsitePayments::Helper
        FIELDS = %w(
          MerchantID LangType MerchantOrderNo Amt ItemDesc TradeLimit ExpireDate ExpireTime ReturnURL NotifyURL CustomerURL ClientBackURL Email EmailModify LoginType OrderComment CREDIT CreditRed InstFlag UNIONPAY ALIPAY WEBATM VACC CVS BARCODE CUSTOM TokenTerm
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
        def detail(data)
          add_field 'Receiver', data[:receiver]
          add_field 'Tel1', data[:phones].first
          add_field 'Tel2', data[:phones].last
          add_field 'Count', data[:items].count
          data[:items].each_with_index do |item, index|
            i = index + 1
            add_field "Pid#{i}", item[:pid]
            add_field "Title#{i}", item[:name]
            add_field "Desc#{i}", item[:description]
            add_field "Price#{i}", item[:price]
            add_field "Qty#{i}", item[:quantity]
          end
        end
        def encrypted_data
          key = OffsitePayments::Integrations::Pay2go.hash_key
          iv = OffsitePayments::Integrations::Pay2go.hash_iv

          aes = OpenSSL::Cipher.new('AES-256-CBC')
          aes.encrypt
          aes.key = key
          aes.iv = iv

          raw_data = URI.encode_www_form OffsitePayments::Integrations::Pay2go::CHECK_VALUE_FIELDS.map { |field|
            [field, @fields[field]]
          }

          trade_info = (aes.update(raw_data) + aes.final).unpack('H*').first

          add_field 'TradeInfo', trade_info
          add_field 'TradeSha', Digest::SHA256.hexdigest("HashKey=#{key}&#{trade_info}&HashIV=#{iv}").upcase
        end
      end

    end
  end
end
