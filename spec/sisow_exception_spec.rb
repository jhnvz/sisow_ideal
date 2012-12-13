require 'spec_helper'

describe SisowIdeal::SisowException do

  before(:each) { @client = SisowIdeal::Client.new(:merchantid => 1, :merchantkey => '1') }

  describe :banklist do

    use_vcr_cassette "errorresponse"

    it { expect { @client.setup_transaction(
      :issuerid     => '01',
      :purchaseid   => '12345',
      :entrancecode => '1',
      :shopid       => '1',
      :amount       => 210,
      :description  => "Test description",
      :returnurl    => 'http://test.com/return',
      :callbackurl  => 'http://test.com/callback',
      :notifyurl    => 'http://test.com/notify'
    ) }.to raise_error(SisowIdeal::SisowException) }

  end

end