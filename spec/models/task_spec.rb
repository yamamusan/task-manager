# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'バリデーション' do
    # let(:base) { create(:base) } # DBに永続化
    let(:base) { build(:base) } # メモリ上に展開

    describe '全項目' do
      context '入力' do
        example 'エラーにならないこと' do
          expect(base).to be_valid
        end
      end
    end

    describe 'タイトル' do
      context '未入力' do
        before { base.title = '' }
        example 'エラーになること' do
          expect(base).to be_invalid
        end
      end
      context '256文字の場合' do
        before { base.title = 'a' * 256 }
        example 'エラーにならないこと' do
          expect(base).to be_valid
        end
      end
      context '257文字の場合' do
        before { base.title = 'a' * 257 }
        example 'エラーになること' do
          expect(base).to be_invalid
        end
      end
    end

    describe '説明' do
      context '未入力' do
        before { base.description = '' }
        example 'エラーにならないこと' do
          expect(base).to be_valid
        end
      end
      context '256文字の場合' do
        before { base.description = 'a' * 257 }
        example 'エラーにならないこと' do
          expect(base).to be_valid
        end
      end
    end
  end

  describe '検索のテスト' do
    # これだと毎回テストデータを入れるので性能がいまいち
    # see: https://www.oiax.jp/rails/tips/initialize-test-data-with-factory-girl.html
    # なおletは遅延評価なので呼ばれたときに評価される、!をつければ毎回評価される
    1.upto(4) { |i| eval "let!(:data#{i}) {create :data#{i}}" }
    let(:task) { Task.new }

    context '条件の指定がない場合' do
      example '全件が取得されること' do
        expect(task.search).to match_array [data1, data2, data3, data4]
      end
      example '特に上限がないこと' do
        create_list(:base, 100)
        expect(task.search.size).to eq 104
      end
    end

    context 'タイトルの指定がある場合' do
      example '存在しない場合は空が変える' do
        task.title = 'nothing'
        expect(task.search.size).to eq 0
      end

      example 'Like検索になっていること' do
        task.title = 'jenkins'
        expect(task.search).to match_array [data1, data2]
        task.title = 'redmine'
        expect(task.search).to match_array [data4]
      end
    end

    context '説明の指定がある場合' do
      example '存在しない場合は空が変える' do
        task.description = 'nothing'
        expect(task.search.size).to eq 0
      end

      example 'Like検索になっていること' do
        task.description = 'cool'
        expect(task.search).to match_array [data1, data2]
        task.description = 'GitLab'
        expect(task.search).to match_array [data4]
      end
    end

    context '複数条件の指定がある場合' do
      example 'AND条件になっていること' do
        task.title = 'jenkins'
        task.description = 'nothing'
        expect(task.search.size).to eq 0
        task.description = 'tool'
        expect(task.search.size).to eq 0
        task.description = 'are'
        expect(task.search).to match_array [data2]
      end
    end

  end
end
