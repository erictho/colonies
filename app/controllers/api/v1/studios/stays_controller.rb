module API
  module V1
    module Studios
      class StaysController < ApplicationController
        def index
          Dry::Matcher::ResultMatcher.call(update_studio_stays) do |matcher|
            matcher.success {  |output| render json: output, status: :ok }
            matcher.failure { |errors| render json: errors, status: :unprocessable_entity }
          end
        end

        private

        def update_studio_stays
          ::Studios::UpdateStaysService.call(studio_id: studio_id, absences_params: absences_params)
        end

        def studio_id
          params.require(:studio_id)
        end

        def absences_params
          params.require(:absences).map do |absence|
            absence.permit(:start_date, :end_date).to_h
          end
        end
      end
    end
  end
end
