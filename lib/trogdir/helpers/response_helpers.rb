module Trogdir
  module ResponseHelpers
    def raise_404
      error!('404 Not Found', 404)
    end

    def elem_match_or_404(klass, conditions)
      klass.elem_match(conditions).first or raise_404
    end
  end
end