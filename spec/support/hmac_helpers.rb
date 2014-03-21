module HMACHelpers
  def app
    Trogdir::API
  end

  def signed_get(url, params = nil, &block)
    signed_request(:get, url, params, &block)
  end

  def signed_request(method, url, params = nil, &block)
    syncinator = FactoryGirl.create :syncinator
    env = Rack::MockRequest.env_for(url, method: method, params: params)

    req = Rack::Request.new(env).tap do |r|
      ApiAuth.sign! r, syncinator.access_id, syncinator.secret_key
    end

    Rack::MockResponse.new(*app.call(req.env)).tap do |resp|
      block.call(resp) if block_given?
    end
  end
end