module Api
  module V1
    class AbsencesController < ApplicationController
      def index
        absences = ::FetchAbsencesService.call.value!

        render json: absences, status: :ok
      end
    end
  end
end
