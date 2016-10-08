[![Gem Version](https://badge.fury.io/rb/active_merchant_pay2go.svg)](https://badge.fury.io/rb/active_merchant_pay2go)
[![Build Status](https://travis-ci.org/imgarylai/active_merchant_pay2go.svg?branch=master)](https://travis-ci.org/imgarylai/active_merchant_pay2go)
[![Code Climate](https://codeclimate.com/github/imgarylai/active_merchant_pay2go/badges/gpa.svg)](https://codeclimate.com/github/imgarylai/active_merchant_pay2go)

# ActiveMerchantPay2go

[![Join the chat at https://gitter.im/imgarylai/active_merchant_pay2go](https://badges.gitter.im/imgarylai/active_merchant_pay2go.svg)](https://gitter.im/imgarylai/active_merchant_pay2go?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

這個 gem 的目的是要串接 [pay2go(智付寶)](https://www.pay2go.com/) 的金流，不過不是只有單純的 API 封裝，是透過 [active_merchant](https://github.com/activemerchant/active_merchant) 和 [offsite_payments](https://github.com/activemerchant/offsite_payments) 包裝後可以快速的在 Rails 上使用。

另外非常感謝 [active_merchant_allpay](https://github.com/xwaynec/active_merchant_allpay)。

## 安裝

Gemfile 中加入這一行

```ruby
gem 'active_merchant_pay2go'
```

透過 bundle 安裝:

```
$ bundle
```

## 設定

- 建議第一次使用的人可以先看一下官方的文件... [official API](https://www.pay2go.com/dw_files/info_api/pay2go_gateway_MPGapi_V1_1_8.pdf) 。

- 建立 `config/initializers/pay2go.rb`
``` sh
rails g pay2go:install
```

- 到智付寶上申請申請相關的 key 並放入 `config/initializers/pay2go.rb` 中。
```rb
# Example
OffsitePayments::Integrations::Pay2go.setup do |pay2go|
  # You have to apply credential below by yourself.
  pay2go.merchant_id = '123456'
  pay2go.hash_key    = 'xxx'
  pay2go.hash_iv     = 'yyy'
end
```

- 環境設定:
```rb
# config/environments/development.rb
config.after_initialize do
  ActiveMerchant::Billing::Base.mode = :development
end
```
```rb
# config/environments/production.rb
config.after_initialize do
  ActiveMerchant::Billing::Base.mode = :production
end
```

## 範例

```erb
<% payment_service_for  @order,
                        @order.user.email,
                        service: :pay2go,
                        html: { :id => 'pay2go-form', :method => :post } do |service| %>
  <% service.time_stamp @order.created_at %>
  <% service.merchant_order_no @order.id %>
  <% service.amt @order.total_amount.to_i %>
  <% service.item_desc @order.description %>
  <% service.email @order.user.email %>
  <% service.login_type 0 %>
  <% service.encrypted_data %>
  <%= submit_tag '付款' %>
<% end %>
```
這段程式碼只有實做了很基本的功能。

如果有更多的設定，建議看一下官方文件有沒有支援。

[範例](https://github.com/imgarylai/rails_active_merchant_pay2go) （很簡陋的範例）.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/imgarylai/active_merchant_pay2go. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
