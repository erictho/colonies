Studio.destroy_all

ActiveRecord::Base.transaction do
  studio1 = Studio.create!(name: 'studio1')
  studio2 = Studio.create!(name: 'studio2')
  studio3 = Studio.create!(name: 'studio3')
  Studio.create!(name: 'studio4')

  studio5 = Studio.create!(name: 'studio5')

  studio1_stays = [
    { start_date: Date.parse('01/01/2024'), end_date: Date.parse('08/01/2024') },
    { start_date: Date.parse('16/01/2024'), end_date: Date.parse('24/01/2024') }
  ]
  studio1.stays.create!(studio1_stays)

  studio2_stays = [
    { start_date: Date.parse('05/01/2024'), end_date: Date.parse('10/01/2024') },
    { start_date: Date.parse('15/01/2024'), end_date: Date.parse('20/01/2024') },
    { start_date: Date.parse('21/01/2024'), end_date: Date.parse('25/01/2024') }
  ]
  studio2.stays.create!(studio2_stays)

  studio3_stays = [
    { start_date: Date.parse('05/01/2024'), end_date: Date.parse('10/01/2024') }
  ]
  studio3.stays.create!(studio3_stays)

  studio5_stays = [
    { start_date: Date.parse('02/02/2024'), end_date: Date.parse('13/02/2024') },
    { start_date: Date.parse('01/03/2024'), end_date: Date.parse('31/03/2024') },
    { start_date: Date.parse('15/04/2024'), end_date: nil }
  ]
  studio5.stays.create!(studio5_stays)
end
