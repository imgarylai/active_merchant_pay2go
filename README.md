[![Gem Version](https://badge.fury.io/rb/active_merchant_pay2go.svg)](https://badge.fury.io/rb/active_merchant_pay2go)
[![Build Status](https://travis-ci.org/imgarylai/active_merchant_pay2go.svg?branch=master)](https://travis-ci.org/imgarylai/active_merchant_pay2go)
[![Code Climate](https://codeclimate.com/github/imgarylai/active_merchant_pay2go/badges/gpa.svg)](https://codeclimate.com/github/imgarylai/active_merchant_pay2go)

# ActiveMerchantPay2go

[![Join the chat at https://gitter.im/imgarylai/active_merchant_pay2go](https://badges.gitter.im/imgarylai/active_merchant_pay2go.svg)](https://gitter.im/imgarylai/active_merchant_pay2go?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

This gem integrate Rails with [pay2go(智付寶)](https://www.pay2go.com/).

It was inspired by [active_merchant_allpay](https://github.com/xwaynec/active_merchant_allpay).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_merchant_pay2go'
```

And then execute:

```
$ bundle
```

## Setup

- I would suggest reading the [official API](https://www.pay2go.com/dw_files/info_api/pay2go_gateway_MPGapi_V1_1_8.pdf) first.

- Create file `config/initializers/pay2go.rb`
``` sh
rails g pay2go:install
```

- Go to Pay2go and get your credential information. Then fill in `config/initializers/pay2go.rb`
```rb
OffsitePayments::Integrations::Pay2go.setup do |pay2go|
  # You have to apply credential below by yourself.
  pay2go.merchant_id = '123456'
  pay2go.hash_key    = 'xxx'
  pay2go.hash_iv     = 'yyy'
end
```

- Environment configuration:
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

## Example

```
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
This example code only fulfill the min requirements.

To customize settings, you should read the documents.
I put some comments in the [code](https://github.com/imgarylai/active_merchant_pay2go/blob/master/lib/offsite_payments/integrations/pay2go.rb) as well!

Here is an [example app](https://github.com/imgarylai/rails_active_merchant_pay2go) though it is really rough.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/imgarylai/active_merchant_pay2go. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
