module Trogdir
  module RequestHelpers
    def clean_params(options = {})
      exceptions = Array(options[:except])

      cleaned_params = params.except(*(['route_info'] + exceptions))

      declared(cleaned_params, include_missing: false)
    end
  end
end
