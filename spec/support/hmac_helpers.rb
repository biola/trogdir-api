module HMACHelpers
  def app
    Trogdir::API
  end

  [:get, :post, :put, :delete].each do |verb|
    define_method("signed_#{verb}") { |url, params| signed_request(verb, url, params) }
  end

  def signed_request(method, url, params = nil)
    syncinator = FactoryGirl.create :syncinator
    env = Rack::MockRequest.env_for(url, method: method, params: params)

    req = Rack::Request.new(env).tap do |r|
      ApiAuth.sign! r, syncinator.access_id, syncinator.secret_key
    end

    Rack::MockResponse.new *app.call(req.env)
  end
end