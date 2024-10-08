# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::AbsencesController, type: :request do
  subject(:request) do
    get api_v1_absences_path
  end

  let!(:studio1) { create(:studio, name: 'studio1') }
  let!(:studio2) { create(:studio, name: 'studio2') }
  let!(:studio3) { create(:studio, name: 'studio3') }
  let!(:studio4) { create(:studio, name: 'studio4') }
  let!(:studio1_stays) do
    [
      create(
        :stay,
        studio: studio1,
        start_date: Date.parse('01/01/2024'),
        end_date: Date.parse('08/01/2024')
      ),
      create(
        :stay,
        studio: studio1,
        start_date: Date.parse('16/01/2024'),
        end_date: Date.parse('24/01/2024')
      )
    ]
  end

  let!(:studio2_stays) do
    [
      create(
        :stay, studio: studio2, start_date: Date.parse('05/01/2024'), end_date: Date.parse('10/01/2024')
      ),
      create(
        :stay, studio: studio2, start_date: Date.parse('15/01/2024'), end_date: Date.parse('20/01/2024')
      ),
      create(
        :stay, studio: studio2, start_date: Date.parse('21/01/2024'), end_date: Date.parse('25/01/2024')
      )
    ]
  end

  let!(:studio3_stays) do
    create(
      :stay, studio: studio3, start_date: Date.parse('05/01/2024'), end_date: Date.parse('10/01/2024')
    )
  end

  before { request }

  let(:expected_absences) do
    {
      "studio1" => [
        {
          "start_date"=>"2024-01-09",
          "end_date"=>"2024-01-15"
        },
        {
          "start_date"=>"2024-01-25",
          "end_date"=>nil
        }
      ],
     "studio2"=>[
       {"start_date"=>"2024-01-01", "end_date"=>"2024-01-04"},
       {"start_date"=>"2024-01-11", "end_date"=>"2024-01-14"},
       {"start_date"=>"2024-01-26", "end_date"=>nil}
     ],
     "studio3"=>[
       {"start_date"=>"2024-01-01", "end_date"=>"2024-01-04"}, {"start_date"=>"2024-01-11", "end_date"=>nil}
     ],
     "studio4"=>[
       {
         "start_date" =>"2024-01-01",
         "end_date" => nil
       }
     ]
    }
  end

  it 'renders absences for each studio' do
    expect(response.status).to eq(200)
    expect(JSON.parse(response.body)).to eq(expected_absences)
  end
end
