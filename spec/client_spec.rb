require 'spec_helper'

describe SisowIdeal::Client do

  before(:each) { @client = SisowIdeal::Client.new(:merchantid => 12345, :merchantkey => '5a48c58eabfcb4c') }

  describe :banklist do

    subject { @client }

    use_vcr_cassette "banklist"

    its(:banklist) { should == [
      ["ABN Amro Bank", "01"],
      ["ASN Bank", "02"],
      ["Friesland Bank", "04"],
      ["ING", "05"],
      ["Rabobank", "06"],
      ["SNS Bank", "07"],
      ["RegioBank", "08"],
      ["Triodos Bank", "09"],
      ["Van Lanschot Bankiers", "10"],
      ["Knab", "11"]]
    }

  end

  describe :setup_transaction do

    use_vcr_cassette "setup_transaction"

    context 'missing options' do

      it { expect { @client.setup_transaction({}) }.to raise_error(ArgumentError) }

    end

    subject { @client.setup_transaction(
      :issuerid     => '01',
      :purchaseid   => '12345',
      :entrancecode => '1',
      :shopid       => '1',
      :amount       => 210,
      :description  => "Test description",
      :returnurl    => 'http://test.com/return',
      :callbackurl  => 'http://test.com/callback',
      :notifyurl    => 'http://test.com/notify'
    ) }

    its(:trxid) { should == '0050001157723256' }
    its(:url) { should == 'https://www.abnamro.nl/nl/ideal/identification.do?randomizedstring=3722692644&trxid=50001157723256' }

  end

  describe :status_request do

    use_vcr_cassette "status_request"

    context 'missing options' do

      it { expect { @client.status_request({}) }.to raise_error(ArgumentError) }

    end

    subject { @client.status_request(
      :trxid  => '0050001157723256',
      :shopid => '1'
    ) }

    its(:status) { should == 'Open' }

  end

  describe :valid_response? do

    subject { @client.valid_response?(params) }

    context 'invalid' do

      let!(:params) { {
        :trxid  => '0050001157723256',
        :ec     => '123',
        :status => 'Open',
        :sha1   => 'f334d33574f5b9244f8e434a7e4bc3cee12f6284'
      } }

      it { subject.should be_false }

    end

    context 'valid' do

      let!(:params) { {
        :trxid  => '0050001157723256',
        :ec     => '1',
        :status => 'Open',
        :sha1   => 'f334d33574f5b9244f8e434a7e4bc3cee12f6284'
      } }

      it { subject.should be_true }

    end

  end


end