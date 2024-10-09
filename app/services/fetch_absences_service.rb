# frozen_string_literal: true

class FetchAbsencesService < ApplicationService
  DEFAULT_OPEN_DATE = Date.parse("2024-01-01").freeze

  option :studio_repository, default: -> { StudioRepository }

  def call
    absences = fetch_studios_with_stays.each_with_object({}) do |studio, acc|
      acc[studio.name] = add_absences(studio.stays)
    end

    Success(absences)
  end

  private

  def fetch_studios_with_stays
    @studio_repository.fetch_studios_with_stays
  end

  def add_absences(stays)
    return [ { start_date: DEFAULT_OPEN_DATE, end_date: nil } ] if stays.blank?

    [
      add_initial_absence(stays.first),
      add_absence_between_stays(stays),
      add_last_absence(stays.last)
    ].flatten.compact
  end

  def add_initial_absence(first_stay)
    return if first_stay[:start_date] <= DEFAULT_OPEN_DATE

    { start_date: DEFAULT_OPEN_DATE, end_date: first_stay[:start_date] - 1 }
  end

  def add_absence_between_stays(stays)
    stays.each_cons(2).map do |previous_stay, next_stay|
      if next_stay[:start_date] > previous_stay[:end_date] + 1
        { start_date: previous_stay[:end_date] + 1, end_date: next_stay[:start_date] - 1 }
      end
    end
  end

  def add_last_absence(last_stay)
    return if last_stay[:end_date].nil?

    { start_date: last_stay[:end_date] + 1, end_date: nil }
  end
end
