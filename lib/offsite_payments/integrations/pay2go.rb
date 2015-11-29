# encoding: utf-8
require 'digest'

module OffsitePayments #:nodoc:
  module Integrations #:nodoc:
    module Pay2go

      VERSION = '1.2'
      RESPOND_TYPE = 'String'
      CHECK_VALUE_FIELDS = [
        'Amt',
        'MerchantID',
        'MerchantOrderNo',
        'TimeStamp',
        'Version'
      ]

      CHECK_CODE_FIELDS = [
        'Amt',
        'MerchantID',
        'MerchantOrderNo',
        'TradeNo'
      ]

      mattr_accessor :service_url
      mattr_accessor :merchant_id
      mattr_accessor :hash_key
      mattr_accessor :hash_iv
      mattr_accessor :debug

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
        # 商店代號 *
        mapping :merchant_id, 'MerchantID'
        mapping :account, 'MerchantID' # AM common
        # 語系
        mapping :lang_type, 'LangType'
        # 廠商交易編號 *
        mapping :merchant_order_no, 'MerchantOrderNo'
        # 交易金額
        mapping :amt, 'Amt'
        mapping :amount, 'Amt' # AM common
        # 商品資訊 *
        mapping :item_desc, 'ItemDesc'
        # 交易限制秒數
        mapping :trade_limit, 'TradeLimit'
        # 繳費有效期限(適用於非即時交易))
        mapping :expire_date, 'ExpireDate'
        # 支付完成返回商店網址
        mapping :return_url, 'ReturnURL'
        # 支付通知網址
        mapping :notify_url, 'NotifyURL'
        # CustomerURL
        mapping :customer_url, 'CustomerURL'
        # Client 端返回廠商網址
        mapping :client_back_url, 'ClientBackURL'
        # 付款人電子信箱 *
        mapping :email, 'Email'
        # 付款人電子信箱是否開放修改
        mapping :email_modify, 'EmailModify'
        # 智付寶會員 *
        mapping :login_type, 'LoginType'
        # 商店備註
        mapping :order_comment, 'OrderComment'
        # 信用卡一次付清啟用
        mapping :credit ,'CREDIT'
        # 信用卡紅利啟用
        mapping :credit_red, 'CreditRed'
        # 信用卡分期付款啟用
        mapping :inst_flag ,'InstFlag'
        # 信用卡銀聯卡啟用
        mapping :unionpay ,'UNIONPAY'
        # WEBATM 啟用
        mapping :webatm, 'WEBATM'
        # ATM 轉帳啟用
        mapping :vacc, 'VACC'
        # 超商代碼繳費啟用
        mapping :cvs, 'CVS'
        # 條碼繳費啟用
        mapping :barcode, 'BARCODE'
        # 自訂支付啟用
        mapping :custom, 'CUSTOM'
        # 快速結帳 *
        mapping :token_term, 'TokenTerm'

        def initialize(order, account, options = {})
          super
          add_field 'MerchantID', OffsitePayments::Integrations::Pay2go.merchant_id
          add_field 'Version', OffsitePayments::Integrations::Pay2go::VERSION
          add_field 'RespondType', OffsitePayments::Integrations::Pay2go::RESPOND_TYPE
        end

        def time_stamp(date)
          add_field 'TimeStamp', date.to_time.to_i
        end

        def encrypted_data
          raw_data = OffsitePayments::Integrations::Pay2go::CHECK_VALUE_FIELDS.sort.map { |field|
            "#{field}=#{@fields[field]}"
          }.join('&')

          hash_raw_data = "HashKey=#{OffsitePayments::Integrations::Pay2go.hash_key}&#{raw_data}&HashIV=#{OffsitePayments::Integrations::Pay2go.hash_iv}"

          binding.pry if OffsitePayments::Integrations::Pay2go.debug

          add_field 'CheckValue', Digest::SHA256.hexdigest(hash_raw_data).upcase
        end

      end

      class Notification < OffsitePayments::Notification

        def success?
          @params['Status'] == 'SUCCESS' ? true : false
        end

        # TODO 使用查詢功能實作 acknowledge
        # Pay2go 沒有遠端驗證功能，
        # 而以 checksum_ok? 代替
        def acknowledge
          checksum_ok?
        end

        def complete?
          case @params['Status']
          when 'SUCCESS'
            true
          when 'CUSTOM'
            true
          else
            false
          end
        end

        def checksum_ok?
          params_copy = @params.clone

          checksum = params_copy['CheckCode']

          raw_data = OffsitePayments::Integrations::Pay2go::CHECK_CODE_FIELDS.sort.map { |field|
            "#{field}=#{params_copy[field]}"
          }.join('&')

          hash_raw_data = "HashIV=#{OffsitePayments::Integrations::Pay2go.hash_iv}&#{raw_data}&HashKey=#{OffsitePayments::Integrations::Pay2go.hash_key}"

          Digest::SHA256.hexdigest(hash_raw_data).upcase == checksum
        end

        def status
          @params['Status']
        end

        def message
          @params['Message']
        end

        def merchant_id
          @params['MerchantID']
        end

        def amt
          @params['Amt']
        end

        def trade_no
          @params['TradeNo']
        end

        def merchant_order_no
          @params['MerchantOrderNo']
        end

        def payment_type
          @params['PaymentType']
        end

        def respond_type
          @params['RespondType']
        end

        def check_code
          @params['CheckCode']
        end

        # 所有支付方式共同回傳參數

        def pay_time
          @params['PayTime']
        end

        def ip
          @params['IP']
        end

        def escrow_bank
          @params['EscrowBank']
        end

        def token_use_status
          @params['TokenUseStatus']
        end

        # 信用卡支付回傳參數

        def respond_code
          @params['RespondCode']
        end

        def auth
          @params['Auth']
        end

        def card_6_no
          @params['Card6No']
        end

        def card_4_no
          @params['Card4No']
        end

        def inst
          @params['Inst']
        end

        def inst_first
          @params['InstFirst']
        end

        def inst_each
          @params['InstEach']
        end

        def eci
          @params['ECI']
        end

        # WEBATM、ATM 繳費回傳參數

        def pay_bank_code
          @params['PayBankCode']
        end

        def payer_account_5_code
          @params['PayerAccount5Code']
        end

        # 超商代碼繳費回傳參數

        def code_no
          @params['CodeNo']
        end

        # ATM 轉帳回傳參數
        def bank_code
          @params['BankCode']
        end


        # 條碼繳費回傳參數

        def barcode_1
          @params['Barcode_1']
        end

        def barcode_2
          @params['Barcode_2']
        end

        def barcode_3
          @params['Barcode_3']
        end

        # 取號完成系統回傳參數

        def expire_date
          @params['ExpireDate']
        end

      end
    end
  end
end
