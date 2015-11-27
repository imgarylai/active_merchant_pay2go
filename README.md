# ActiveMerchantPay2go

This gem integrate Rails with [pay2go(智付寶)](https://www.pay2go.com/).

It was inspired by [active_merchant_allpay](https://github.com/xwaynec/active_merchant_allpay).

*WARNING:* This gem is not fully tested.

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

1. I would suggest reading the [official API](https://www.pay2go.com/dw_files/info_api/pay2go_gateway_Transaction_api_V1_0_2.pdf) first.

2. Create file `config/initializers/allpay.rb`

``` rb
OffsitePayments::Integrations::Pay2go.setup do |pay2go|
  # You have to apply credential below by yourself.
  pay2go.merchant_id = 'xxx'
  pay2go.hash_key    = 'xxx'
  pay2go.hash_iv     = 'xxx'
end
```

3. Environment configuration:

```rb
# config/environments/development.rb
config.after_initialize do
  ActiveMerchant::Billing::Base.integration_mode = :development
end
```

```rb
# config/environments/production.rb
config.after_initialize do
  ActiveMerchant::Billing::Base.integration_mode = :production
end
```

## Example

```rb
<% payment_service_for  @order,
                        @order.user.email,
                        service: :pay2go,
                        html: { :id => 'pay2go-form', :method => :post } do |service| %>
  <% service.encrypted_data %>
  <% service.time_stamp @order.created_at %>
  <% service.merchant_order_no @order.id %>
  <% service.amt @order.total_amount.to_i %>
  <% service.item_desc @order.description %>
  <% service.email @order.user.email %>
  <% service.login_type 0 %>
  <%= submit_tag '付款' %>
<% end %>
```

To customize settings, you can read the documents.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/imgarylai/active_merchant_pay2go. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
