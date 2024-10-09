require 'rails_helper'

describe Studios::UpdateStaysService, type: :service do
  subject(:service) { instance.call(studio_id: studio_id, absences_params: absences_params) }

  let(:instance) do
    described_class.new(
      studio_repository: studio_repository,
      stay_repository: stay_repository,
      overlapping_adjuster: overlapping_adjuster
    )
  end
  let(:studio_repository) { class_double('StudioRepository', find: studio) }
  let(:studio) { double('Studio') }

  let(:stay_repository) { class_double('StayRepository', find_all_by_studio: new_stays) }
  let(:new_stays) { [double('Stay')] }
  let(:overlapping_adjuster) { ->(*) { adjuster_response } }
  let(:adjuster_response) { Dry::Monads::Success('new stays') }

  let(:studio_id) { 1 }
  let(:absences_params) do
    [
      {"start_date"=>"2024-03-03", "end_date"=>"2024-03-15"},
      {"start_date"=>"2024-03-25", "end_date"=>"2024-04-06"}
    ]
  end

  context 'when validation fails' do
    context 'when absences params is empty' do
      let(:absences_params) { [] }

      let(:expected_errors) do
        { errors: { absences: ["size cannot be less than 1"] } }
      end

      it { expect(service.failure).to eq(expected_errors) }
    end

    context 'when start_date is missing' do
      let(:absences_params) { [{"end_date"=>"2024-03-15"}] }

      let(:expected_errors) do
        {errors: {absences: {0=>{start_date: ["is missing"]}}}}
      end

      it { expect(service.failure).to eq(expected_errors) }
    end

    context 'when end_date is missing' do
      let(:absences_params) { [{"start_date"=>"2024-03-15"}] }

      let(:expected_errors) do
        {errors: {absences: {0=>{end_date: ["is missing"]}}}}
      end

      it { expect(service.failure).to eq(expected_errors) }
    end

    context 'when start_date comes after end_date' do
      let(:absences_params) { [{"start_date"=>"2025-03-03", "end_date"=>"2024-03-15"}] }

      let(:expected_errors) do
        { errors: { absences: { 0 => ["end_date must be greater than start_date"] } } }
      end

      it { expect(service.failure).to eq(expected_errors) }
    end
  end

  context 'when studio is not found' do
    let(:studio) { nil }

    it { expect(service.failure).to eq(errors: :resource_not_found) }
  end

  context 'when adjuster fails' do
    let(:adjuster_response) { Dry::Monads::Failure('some error') }

    it { expect(service.failure).to eq('some error') }
  end

  context 'when adjuster succeeds' do
    it { expect(service.value!).to eq(new_stays) }
  end
end
