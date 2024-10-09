# frozen_string_literal: true

class StudioRepository < ApplicationRepository
  def self.fetch_studios_with_stays(sort_by:, sort_dir:)
    Studio.includes(:stays).left_joins(:stays).order("studios.name", sort_by => sort_dir)
  end
end
