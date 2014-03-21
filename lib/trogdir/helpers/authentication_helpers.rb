module AuthenticationHelpers
  def authentic?
    request = Rack::Request.new(@env)
    access_id = ApiAuth.access_id(request)
    secret_key = Syncinator.where(access_id: access_id).first.try(:secret_key)

    ApiAuth.authentic? request, secret_key
  end

  def authenticate!
     error!('401 Unauthorized', 401) unless authentic?
  end
end