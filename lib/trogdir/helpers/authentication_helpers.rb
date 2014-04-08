module AuthenticationHelpers
  def rack_request
    Rack::Request.new(@env)
  end

  def current_syncinator
    access_id = ApiAuth.access_id(rack_request)
    Syncinator.where(access_id: access_id).first
  end

  def authentic?
    secret_key = current_syncinator.try(:secret_key)

    ApiAuth.authentic? rack_request, secret_key
  end

  def authenticate!
     unauthorized! unless authentic?
  end

  def unauthorized!
    error!('401 Unauthorized', 401)
  end
end