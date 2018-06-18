# frozen_string_literal: true

require 'rails_helper'
require 'database_cleaner'

steps_for :common do
  step 'トップ画面にアクセス' do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
    visit root_path
  end
end

steps_for :new do
  step '新規登録ボタンを押下' do
    click_button '新規登録'
  end

  step '新規登録用の子画面が表示される' do
    sleep 2
    expect(page).to have_css '#task-register.show'
    expect(find_field('タイトル').value).to eq ''
    expect(find_field('説明').value).to eq ''
    expect(page).to have_select('優先度', selected: '中')
    expect(page).to have_select('ステータス', selected: '新規')
    expect(find_field('期限').value).to eq ''
    expect(page).to have_button '新規登録'
  end

  step '正常な値を入力' do
    fill_in 'title', with: 'タイトル'
    fill_in 'description', with: "これは説明です。\n改行しました"
    select '高', from: 'priority'
    select '着手', from: 'status'
    # TODO: 日付の入力がうまくいかない
    # fill_in 'due-date', with: '2018-10-10'
  end

  step '登録ボタンを押下' do
    click_button 'register-btn'
    sleep 1
    page.driver.browser.switch_to.alert.accept
  end

  step '登録が正常に完了すること' do
    sleep 1
    expect(page).not_to have_css '#task-register.show'
    expect(find('#title-1 a').text).to eq 'タイトル'
    expect(find('#priority-1').text).to eq 'high'
    expect(find('#status-1').text).to eq 'doing'
    page.save_screenshot 'task-create.png'
  end
end

steps_for :update do
  step 'タスクを選択' do
    FactoryBot.create(:base)
    visit root_path
    find('#title-1 a').click
  end

  step '更新用の子画面が表示される' do
    sleep 1
    expect(page).to have_css '#task-update.show'
    expect(find_field('タイトル').value).to eq 'This is Title'
    expect(find_field('説明').value).to eq 'Description'
    # expect(page).to have_select('優先度', selected: '中')
    # expect(page).to have_select('ステータス', selected: '新規')
    # expect(find_field('期限').value).to eq ''
    expect(page).to have_button '更新'
  end

  step '正常な値を入力' do
    fill_in 'title', with: 'タイトル'
    fill_in 'description', with: "これは説明です。\n改行しました"
    select '高', from: 'priority'
    select '着手', from: 'status'
    # TODO: 日付の入力がうまくいかない
    # fill_in 'due-date', with: '2018-10-10'
  end

  step '更新ボタンを押下' do
    click_button 'update-btn'
    sleep 1
    page.driver.browser.switch_to.alert.accept
  end

  step '更新が正常に完了すること' do
    sleep 1
    expect(page).not_to have_css '#task-update.show'
    expect(find('#title-1 a').text).to eq 'タイトル'
    expect(find('#priority-1').text).to eq 'high'
    expect(find('#status-1').text).to eq 'doing'
    page.save_screenshot 'task-update.png'
  end
end

steps_for :delete do
  step 'タスクのチェックボックスを選択' do
    1.upto(4) { |i| eval "FactoryBot.create :data#{i}" }
    visit root_path
    check('checkbox-1')
    check('checkbox-3')
    sleep 1
  end

  step '削除ボタンを押下' do
    click_button 'delete-btn'
    sleep 1
    page.driver.browser.switch_to.alert.accept
  end

  step '削除が正常に完了すること' do
    sleep 1
    expect(page).to have_no_css '#id-1'
    expect(page).to have_css '#id-2'
    expect(page).to have_no_css '#id-3'
    expect(page).to have_css '#id-4'
    page.save_screenshot 'task-delete.png'
  end
end

steps_for :delete_all do
  step '一部タスクのチェックボックスを選択' do
    1.upto(4) { |i| eval "FactoryBot.create :data#{i}" }
    visit root_path
    check('checkbox-1')
    check('checkbox-3')
    sleep 1
  end

  step '一括選択のチェックボックス選択' do
    check('checkbox-header')
  end

  step '全てのチェックボックスがチェックされていること' do
    1.upto(4) do |i|
      expect(page).to have_checked_field("checkbox-#{i}")
      page.save_screenshot 'task-checked.png'
    end
  end

  step 'hogehoge' do
    sleep 1
    uncheck('checkbox-header')
  end

  step '全てのチェックボックスのチェックが外れていること' do
    1.upto(4) do |i|
      expect(page).to have_unchecked_field("checkbox-#{i}")
      page.save_screenshot 'task-unchecked.png'
    end
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
