module AuthenticationHelpers
  def current_syncinator
    request = Rack::Request.new(@env)
    access_id = ApiAuth.access_id(request)
    Syncinator.where(access_id: access_id).first
  end

  def authentic?
    request = Rack::Request.new(@env)
    secret_key = current_syncinator.try(:secret_key)

    ApiAuth.authentic? request, secret_key
  end

  def authenticate!
     error!('401 Unauthorized', 401) unless authentic?
  end
end