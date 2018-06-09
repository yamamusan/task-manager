# frozen_string_literal: true

FactoryBot.define do
  factory :base, class: 'Task' do
    title 'This is Title'
    description 'Description'
  end
  factory :data1, class: 'Task' do
    title 'Jenkins'
    description 'Jenkins is cool'
  end
  factory :data2, class: 'Task' do
    title 'Jenkins And GitLab'
    description 'Teher are cool'
  end
  factory :data3, class: 'Task' do
    title 'GitLab'
    description 'nice tool'
  end
  factory :data4, class: 'Task' do
    title 'redmine'
    description 'communicate GitLab'
  end
end
