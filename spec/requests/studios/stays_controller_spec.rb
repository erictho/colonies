# frozen_string_literal: true

require 'rails_helper'

## Overlap Edge Cases
# Case 1: absence covering totally a stay
# Case 2: absences covering partially a stay
# - Case 2A: absence covering the stay start date
# - Case 2B: absence covering the stay end date
# Case 3: absence totally covered by a stay
# Case 4: absence covering several stays

RSpec.describe API::V1::Studios::StaysController, type: :request do
  subject(:request) do
    post api_v1_studio_stays_path(studio_id: studio.id), params: params
  end

  let(:studio) { create(:studio, name: 'studio') }
  let!(:studio_stays) do
    [
      create(
        :stay,
        studio: studio,
        start_date: Date.parse('02/02/2024'),
        end_date: Date.parse('13/02/2024')
      ),
      create(
        :stay,
        studio: studio,
        start_date: Date.parse('01/03/2024'),
        end_date: Date.parse('31/03/2024')
      ),
      create(
        :stay,
        studio: studio,
        start_date: Date.parse('15/04/2024'),
        end_date: nil
      )
    ]
  end

  before { request }

  context 'when booking is totally overlapped by an absence' do
    let(:params) do
      {
        "absences": [
          { "start_date": "2024-02-01", "end_date": "2024-02-26" }
        ]
      }
    end

    let(:expected_output) do
      [
        { "start_date"=>"2024-03-01", "end_date"=>"2024-03-31" },
        { "start_date"=>"2024-04-15", "end_date"=>nil }
      ]
    end

    it 'renders the new stays for the requested studio' do
      output = JSON.parse(response.body).map { |hash| hash.slice("start_date", "end_date") }

      expect(response.status).to eq(200)
      expect(output).to match_array(expected_output)
    end
  end

  context 'when booking is partially overlapped by absences' do
    let(:params) do
      {
        "absences": [
          { "start_date": "2024-02-24", "end_date": "2024-03-03" },
          { "start_date": "2024-03-10", "end_date": "2024-03-15" },
          { "start_date": "2024-03-26", "end_date": "2024-04-04" }
        ]
      }
    end

    let(:expected_output) do
      [
        { "start_date"=>"2024-02-02", "end_date"=>"2024-02-13" },
        { "start_date"=>"2024-03-04", "end_date"=>"2024-03-09" },
        { "start_date"=>"2024-03-16", "end_date"=>"2024-03-25" },
        { "start_date"=>"2024-04-15", "end_date"=>nil }
      ]
    end

    it 'renders the new stays for the requested studio' do
      output = JSON.parse(response.body).map { |hash| hash.slice("start_date", "end_date") }

      expect(response.status).to eq(200)
      expect(output).to match_array(expected_output)
    end
  end

  context 'when bookings overlaps totally an absence (not on the edges)' do
    let(:params) do
      {
        "absences": [
          { "start_date": "2024-03-10", "end_date": "2024-03-15" }
        ]
      }
    end

    let(:expected_output) do
      [
        { "start_date"=>"2024-02-02", "end_date"=>"2024-02-13" },
        { "start_date"=>"2024-03-01", "end_date"=>"2024-03-09" },
        { "start_date"=>"2024-03-16", "end_date"=>"2024-03-31" },
        { "start_date"=>"2024-04-15", "end_date"=>nil }
      ]
    end

    it 'renders the new stays for the requested studio' do
      output = JSON.parse(response.body).map { |hash| hash.slice("start_date", "end_date") }

      expect(response.status).to eq(200)
      expect(output).to match_array(expected_output)
    end
  end

  context 'when an absence overlap several stays' do
    let(:params) do
      {
        "absences": [
          { "start_date": "2024-03-05", "end_date": "2024-03-15" }
        ]
      }
    end

    let!(:studio_stays) do
      [
        create(
          :stay,
          studio: studio,
          start_date: Date.parse('01/03/2024'),
          end_date: Date.parse('07/03/2024')
        ),
        create(
          :stay,
          studio: studio,
          start_date: Date.parse('10/03/2024'),
          end_date: Date.parse('12/03/2024')
        ),
        create(
          :stay,
          studio: studio,
          start_date: Date.parse('13/03/2024'),
          end_date: Date.parse('17/03/2024')
        )
      ]
    end

    let(:expected_output) do
      [
        { "start_date"=>"2024-03-01", "end_date"=>"2024-03-04" },
        { "start_date"=>"2024-03-16", "end_date"=>"2024-03-17" }
      ]
    end

    it 'renders the new stays for the requested studio' do
      output = JSON.parse(response.body).map { |hash| hash.slice("start_date", "end_date") }

      expect(response.status).to eq(200)
      expect(output).to match_array(expected_output)
    end
  end
end
