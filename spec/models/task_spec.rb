# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Task, type: :model do
  let(:base) { build(:base) } # メモリ上に展開
  # let(:base) { create(:base) } # DBに永続化

  describe 'バリデーション' do
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
      context '255文字の場合' do
        before { base.title = 'a' * 255 }
        example 'エラーにならないこと' do
          expect(base).to be_valid
        end
      end
      context '256文字の場合' do
        before { base.title = 'a' * 256 }
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
        before { base.description = 'a' * 256 }
        example 'エラーにならないこと' do
          expect(base).to be_valid
        end
      end
    end

  end
end

# context '3の倍数' do
#   example 'Fizzという文字列を返すこと' do
#     expect(FizzBuzz.run(3)).to eq('Fizz')
#     expect(FizzBuzz.run(6)).to eq('Fizz')
#     expect(FizzBuzz.run(9)).to eq('Fizz')
#     expect(FizzBuzz.run(12)).to eq('Fizz')
#   end
# end

# context '5の倍数' do
#   example 'Buzzという文字列を返すこと' do
#     expect(FizzBuzz.run(5)).to eq('Buzz')
#     expect(FizzBuzz.run(10)).to eq('Buzz')
#   end
# end

# context '3の倍数かつ5の倍数' do
#   example 'FizzBuzzという文字列を返すこと' do
#     expect(FizzBuzz.run(15)).to eq('FizzBuzz')
#   end
# end

# context '3の倍数ではない かつ 5の倍数ではない' do
#   example 'そのままの数字を返すこと' do
#     expect(FizzBuzz.run(1)).to eq(1)
#     expect(FizzBuzz.run(2)).to eq(2)
#     expect(FizzBuzz.run(4)).to eq(4)
#   end
# end
