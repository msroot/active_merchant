begin
  require "pay_choice"
rescue LoadError
  raise "Could not load the pay_choice gem.  Use `gem install pay_choice` to install it."
end

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class PayChoiceGateway < Gateway
      # The countries the gateway supports merchants from as 2 digit ISO country codes
      self.supported_countries = ['AU']

      self.money_format = :dollars
      self.default_currency = 'AUD'
      self.supported_cardtypes = [:visa, :master, :american_express, :discover]
      self.homepage_url = "http://www.paychoice.com.au/"
      self.display_name = "PayChoice"

      def initialize(options)
        requires!(options, :login, :password)

        super

        @login = options[:login]
        @password = options[:password]
        @environment = test? ? :sandbox : :production
        @paychoice = PayChoice.new({
          username: @login,
          password: @password
        }, @environment)
      end

      def authorize(money, creditcard, options = {})
        #purchase(money, creditcard, options)
      end

      def purchase(money, creditcard, options = {})
        result = @paychoice.create(
          currency: self.default_currency,
          amount: money,
          reference: "Invoice #{Time.now.to_i}",
          card: to_hash_from_credit_card(creditcard)
        )

        response_from_charge_result result
      end

      def capture(money, authorization, options = {})
        #commit('capture', money, post)
      end
 
      # add credit card details to be stored by Pay Choice.
      def add_creditcard(post, creditcard)
        @paychoie.store_card(to_hash_from_credit_card(creditcard))
      end

     private
     
      def to_hash_from_credit_card(creditcard)
        {
          name: creditcard.name,
          number: creditcard.number,
          expiry_month: sprintf("%.2i", creditcard.month),
          expiry_year: sprintf("%.4i", creditcard.year)[-2..-1],
          cvv: creditcard.verification_value
        }
      end

      def response_from_charge_result result
        Response.new result['charge']['status_code'] == 0,
                     result['charge']['status'],
                     {},
                     test: test?
      end
    end
  end
end

