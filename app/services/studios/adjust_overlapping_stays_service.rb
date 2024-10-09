# frozen_string_literal: true

module Studios
  class AdjustOverlappingStaysService < ApplicationService
    option :stay_repository, default: -> { StayRepository }

    def call(studio:, absences_ranges:)
      @studio = studio
      @absences_ranges = absences_ranges

      transaction do
        delete_stays_totally_overlapped

        new_stays_attrs = fetch_stays_partially_overlapped.flat_map { |_, stay| build_stays(stay) }
        remove_existing_stays
        create_new_stays(new_stays_attrs)
      end
    end

    private

    def delete_stays_totally_overlapped
      @absences_ranges.each do |absence_range|
        @stay_repository.remove_all_covered_by(studio: @studio, date_range: absence_range)
      end
    end

    def fetch_stays_partially_overlapped
      @fetch_stays_partially_overlapped ||= @absences_ranges.each_with_object({}) do |absence_range, acc|
        find_stays_partially_covered(absence_range).each do |stay|
          acc[stay.id] ||= { start_date: stay.start_date, end_date: stay.end_date, absences: [] }
          acc[stay.id][:absences] << absence_range
        end
      end
    end

    def build_stays(stay)
      [
        build_initial_stay(stay, stay[:absences].first),
        build_stay_between_absences(stay[:absences]),
        build_final_stay(stay, stay[:absences].last)
      ].flatten.compact
    end

    def remove_existing_stays
      overlapped_stay_ids = fetch_stays_partially_overlapped.keys

      @stay_repository.remove_all_by_ids(overlapped_stay_ids)
    end

    def create_new_stays(stays_attrs)
      Success(@stay_repository.create(stays_attrs))
    end

    def find_stays_partially_covered(absence)
      @stay_repository.find_all_partially_covered(studio: @studio, date_range: absence)
    end

    def build_initial_stay(stay, first_absence)
      return if first_absence[:start_date] <= stay[:start_date]

      { start_date: stay[:start_date], end_date: first_absence[:start_date] - 1, studio_id: @studio.id }
    end

    def build_stay_between_absences(absences)
      absences.each_cons(2).map do |previous_abs, next_abs|
        if next_abs[:start_date] > previous_abs[:end_date] + 1
          { start_date: previous_abs[:end_date] + 1, end_date: next_abs[:start_date] - 1, studio_id: @studio.id }
        end
      end
    end

    def build_final_stay(stay, last_absence)
      return { start_date: last_absence[:end_date] + 1, end_date: nil, studio_id: @studio.id } if stay[:end_date].nil?
      return if last_absence[:end_date] >= stay[:end_date]

      { start_date: last_absence[:end_date] + 1, end_date: stay[:end_date], studio_id: @studio.id }
    end
  end
end
