module Trogdir
  module RequestHelpers
    def clean_params
      params.except('route_info')
    end
  end
end