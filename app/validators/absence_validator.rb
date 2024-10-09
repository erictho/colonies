# frozen_string_literal: true

class AbsenceValidator < ApplicationValidator
  params do
    required(:absences).value(:array, min_size?: 1).each do
      hash do
        required(:start_date).filled(:date)
        required(:end_date).filled(:date)
      end
    end
  end

  rule(:absences).each do
    if value[:end_date] <= value[:start_date]
      key.failure("end_date must be greater than start_date")
    end
  end
end
