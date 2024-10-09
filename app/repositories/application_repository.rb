# frozen_string_literal: true

class ApplicationRepository
  class << self
    def data_source
      @data_source ||= name.sub(/Repository$/, "").constantize
    end

    def create(attributes)
      data_source.create!(attributes)
    end

    def find(id)
      data_source.where(id: id).first
    end
  end
end
