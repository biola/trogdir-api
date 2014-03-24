module Trogdir
  module RequestHelpers
    def clean_params(options = {})
      exceptions = Array(options[:except])
      params.except(*(['route_info'] + exceptions))
    end
  end
end