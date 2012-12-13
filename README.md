## Sisow iDeal [![Build Status](https://secure.travis-ci.org/jhnvz/sisow_ideal.png?branch=master)](http://travis-ci.org/jhnvz/sisow_ideal)

Wrapper for the mollie ideal api

Installation
------------

1. Add `gem 'sisow_ideal'` to your Gemfile.
1. Run `bundle install`.

## Usage
```ruby
# for production
client = SisowIdeal::Client.new(:merchantid => 12345, :merchantkey => '5a48c58eabfcb4c')

# testmode
client = SisowIdeal::Client.new(:merchantid => 12345, :merchantkey => '5a48c58eabfcb4c', :test => true)

# Example of how to get the banklist and populate a selectbox
@banks = client.banklist
= select_tag :bank_id, options_for_select(@banks)

# How to setup a payment
response = client.setup_transaction(
  :issuerid     => '01',
  :purchaseid   => '12345',
  :entrancecode => '1',
  :shopid       => '1',
  :amount       => 210,
  :description  => "Test description",
  :returnurl    => 'http://test.com/return',
  :callbackurl  => 'http://test.com/callback',
  :notifyurl    => 'http://test.com/notify'
)
order.update_attributes(:trxid => response.trxid)
redirect_to response.url

# How to handle report on the report url
# For safety reasons mollie calls a report url for updating payment status before redirecting back to the application
order = Order.find_by_trxid(params[:trxid])
response = client.status_request(
  :trxid  => order.trxid,
  :shopid => '1'
)
order.update_attributes(:status => response.status)

# When mollie redirects the user back you can check if the payment was succesfull bij finding the order object
@order = Order.find_by_trxid(params[:trxid])
```
## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2010 Johan van Zonneveld. See LICENSE for details.