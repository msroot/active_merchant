require 'test_helper'

class PayChoiceTest < Test::Unit::TestCase
  def setup
    @gateway = PayChoiceGateway.new(
      login: "44f79424-2fdb-49e3-98a6-fc8d27de9934",
      password: "f2B9E=B{9URs"
    )

    @credit_card = credit_card
    @amount = 100
  end

  def test_successful_purchase


    assert response = @gateway.purchase(@amount, @credit_card)
    assert_instance_of Response, response
    assert_success response
    assert response.test?
    @gateway.expects(:ssl_post).returns(successful_purchase_response)

    # Replace with authorization number from the successful response
    #assert_equal '', response.authorization
  end

  def test_unsuccessful_request
    @gateway.expects(:ssl_post).returns(failed_purchase_response)

    assert response = @gateway.purchase(@amount, @credit_card, @options)
    assert_failure response
    assert response.test?
  end

  private

  # Place raw successful response from gateway here
  def successful_purchase_response
  end

  # Place raw failed response from gateway here
  def failed_purchase_response
  end
end
