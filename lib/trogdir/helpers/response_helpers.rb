module Trogdir
  module ResponseHelpers
    def raise_404(klass, conditions)
      raise Mongoid::Errors::DocumentNotFound.new klass, conditions
    end

    def elem_match_or_404(klass, conditions)
      klass.elem_match(conditions).first or raise_404(klass, conditions)
    end
  end
end