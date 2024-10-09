# frozen_string_literal: true

module Studios
  class UpdateStaysService < ApplicationService
    option :studio_repository, default: -> { StudioRepository }
    option :stay_repository, default: -> { StayRepository }
    option :validator, default: -> { AbsenceValidator.new }
    option :overlapping_adjuster, default: -> { AdjustOverlappingStaysService.new }

    def call(studio_id:, absences_params:)
      validate_absence_params(absences_params).bind do |absences_ranges|
        fetch_studio(studio_id).bind do |studio|
          update_overlapping_stays(studio, absences_ranges).fmap do
            reload_stays(studio)
          end
        end
      end
    end

    private

    def validate_absence_params(absences_params)
      validation = @validator.call(absences: absences_params)

      validation.success? ? Success(validation[:absences]) : Failure(errors: validation.errors.to_h)
    end

    def fetch_studio(studio_id)
      studio = @studio_repository.find(studio_id)

      Maybe(studio).to_result(errors: :resource_not_found)
    end

    def update_overlapping_stays(studio, absences_ranges)
      @overlapping_adjuster.call(studio: studio, absences_ranges: absences_ranges)
    end

    def reload_stays(studio)
      @stay_repository.find_all_by_studio(studio)
    end
  end
end
