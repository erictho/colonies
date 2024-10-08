require 'dry/monads'
require 'dry/initializer'

class ApplicationService
  include Dry::Monads[:result, :do]
  extend Dry::Initializer

  class << self
    def call(...)
      new.call(...)
    end
  end
end
