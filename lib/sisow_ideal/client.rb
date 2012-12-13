module SisowIdeal
  class Client
    include HTTParty
    base_uri 'https://www.sisow.nl/Sisow/iDeal/RestHandler.ashx'

    def initialize(options = {})
      required_options(options, :merchantid, :merchantkey)

      @options = options
    end

    ## Get the banklist
    def banklist
      response = Hashie::Mash.new(
        self.class.get('/DirectoryRequest',
        :query => @options,
        :format => :xml
      ).parsed_response).directoryresponse.directory.issuer

      response.kind_of?(Array) ? response.map { |b| [b.issuername, b.issuerid] } : [response.issuername, response.issuerid]
    end

    ## Setup a transaction
    def setup_transaction(options = {})
      required_options(options, :issuerid, :amount, :description, :returnurl, :callbackurl, :notifyurl, :purchaseid)

      sha1 = [
        options.fetch(:purchaseid),
        options.fetch(:entrancecode),
        options.fetch(:amount),
        options.fetch(:shopid),
        @options.fetch(:merchantid),
        @options.fetch(:merchantkey)
      ].join

      response = Hashie::Mash.new(
        self.class.get('/TransactionRequest',
        :query  => merge_query(options, sha1),
        :format => :xml
      ).parsed_response)

      begin
        return Hashie::Mash.new(
          :url   => CGI.unescape(response.transactionrequest.transaction.issuerurl),
          :trxid => response.transactionrequest.transaction.trxid
        )
      rescue
        raise SisowIdeal::SisowException.new(response.errorresponse.error.errorcode, CGI.unescape(response.errorresponse.error.errormessage))
      end
    end

    def status_request(options = {})
      required_options(options, :trxid, :shopid)

      sha1 = [
        options.fetch(:trxid),
        options.fetch(:shopid),
        @options.fetch(:merchantid),
        @options.fetch(:merchantkey)
      ].join

      response = Hashie::Mash.new(
        self.class.get('/StatusRequest',
        :query  => merge_query(options, sha1),
        :format => :xml
      ).parsed_response)

      begin
        return response.statusresponse.transaction
      rescue
        raise SisowIdeal::SisowException.new(response.errorresponse.error.errorcode, CGI.unescape(response.errorresponse.error.errormessage))
      end
    end

    private

      # Merge options in query
      def merge_query(hash, sha1)
        @options.merge!(hash).merge!(:sha1 => Digest::SHA1.hexdigest(sha1))
      end

      def required_options(options, *args)
        args.each do |key|
          raise ArgumentError.new("No #{key.to_s} supplied") unless options.has_key?(key)
        end
      end
  end
end