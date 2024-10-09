require 'dry/monads'
require 'dry/initializer'

class ApplicationService
  include Dry::Monads[:result, :do, :maybe]
  extend Dry::Initializer

  class << self
    def call(...)
      new.call(...)
    end
  end

  def transaction(&block)
    ActiveRecord::Base.transaction(&block)
  end
end
