class Stay < ApplicationRecord
  belongs_to :studio

  scope :covers_date_in_range, ->(date) {
    where(":date BETWEEN start_date AND COALESCE(end_date, '9999-12-31')", date: date)
  }
end
