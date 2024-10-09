# frozen_string_literal: true

class StudioRepository < ApplicationRepository
  def self.fetch_studios_with_stays
    Studio.includes(:stays).order("studios.name", "stays.start_date")
  end
end
