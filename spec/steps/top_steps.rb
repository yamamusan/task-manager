# frozen_string_literal: true

require 'rails_helper'

steps_for :common do
  step 'トップ画面にアクセス' do
    visit root_path
  end
end

steps_for :new do
  step '新規登録ボタンを押下' do
    click_button '新規登録'
  end

  step '新規登録画面が表示される' do
    expect(page).to have_field 'タイトル'
    expect(page).to have_button '登録'
  end
end

steps_for :search do
  step '詳細検索ボタンを押下' do
    visit root_path
    click_button '詳細検索'
  end

  step '詳細検索画面が表示される' do
    expect(page).to have_field 'タイトル'
    expect(page).to have_button '登録'
  end
end
