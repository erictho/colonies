# frozen_string_literal: true

class StayRepository < ApplicationRepository
  class << self
    def find_all_by_studio(studio)
      studio.stays
    end

    def find_all_partially_covered(studio:, date_range:)
      find_all_by_studio(studio)
        .merge(
          data_source.covers_date_in_range(date_range[:start_date]).or(
            data_source.covers_date_in_range(date_range[:end_date])
          )
        )
    end

    def remove_all_covered_by(studio:, date_range:)
      find_all_by_studio(studio)
        .where("start_date >= ? AND end_date <= ?", date_range[:start_date], date_range[:end_date])
        .delete_all
    end

    def remove_all_by_ids(ids)
      data_source.where(id: ids).delete_all
    end
  end
end
