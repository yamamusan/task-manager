# システム要件

* 自分のタスクを簡単に登録したい
* タスクに終了期限を設定できるようにしたい
* タスクに優先順位をつけたい
* ステータス（未着手・着手・完了）を管理したい
* ステータスでタスクを絞り込みたい
* タスク名・タスクの説明文でタスクを検索したい
* タスクを一覧したい。一覧画面で（優先順位、終了期限などを元にして）ソートしたい
* タスクにラベルなどをつけて分類したい
* ユーザ登録し、自分が登録したタスクだけを見られるようにしたい

# 必要環境

* Ruby 2.5.1
* Rails 5.2.0
* NodeJS 8.11.1
* Yarn

# 作業Step

## install node js

```
brew install nodebrew
mkdir -p ~/.nodebrew/src 
nodebrew install-binary v8.11.1
nodebrew use v8.11.1
``` 

* ~/.zshrcでPATHに /Users/xxx/.nodebrew/current/bin を追加
* source ~/.zshrc

## install yarn

```
npm install --global yarn
```

## Railsプロジェクト作成 

```
bundle install --path vendor/bundle
buner new . -B --webpack=vue --skip-test
```
see:https://qiita.com/naoki85/items/51a8b0f2cbf949d08b11

* .gitignoreに`/vendor`を追加する
* この辺で一度git commitしておく

## 作りたいアプリケーションのイメージを考える

### 画面設計
#### 作業イメージ
* Sketchを使って、UI設計をしてみる
* UIは多分デザイナーがやるんで、軽くやる感じ
* 出来上がったデザインは `design/ui` 以下に保存する

#### 作業Step
* まず、どういった画面が必要になりそうか？
  * タスクの一覧画面(G-1)
    * 新規登録(+)ボタン->タスク新規登録子画面(G-2)
    * 検索ボタン->検索条件設定子画面(G-3) (フリーワードで入力と詳細検索で分けてもいいかも)
    * 一覧のタスクごとに編集ボタン->タスク編集子画面(G-4)
    * 一覧のタスクごとに削除ボタン->削除ダイアログ(できれば次から表示しないチェック)
* まずはSkecthを使って描いてみる
  * templateはWeb Designを選択
  * Runnerっていうプラグインを入れた方がよさそう。
  * Simbol Orgnaizerを使うと、Simboleが良い感じに整理される
  * 色の登録(Symbolでcolor/blueのようにして登録する)
  * アイコンはGoogleのMaterial　Designから引っ張ってこれる(SVGをドラッグ&ドロップで) 
  * 画像の色を変えたい場合は、背景に入れたい色を入れて、Maskをすると反映される 
  * Symbolはクラス化みたいのができるので、似たようなものをパラメータ化できて、変更できる

### データモデル設計
#### 作業イメージ
* Navicat Data Modlerを使って、ER図を作成する
* 出来上がったら、`design/model` 以下に保存する

#### 作業Step
* 概念モデル
  * タスク
    * タイトル
    * 期限
    * 優先度
    * ステータス
  * ユーザー
    * 名前
    * ロール
  * ロール


## #3　自分のタスクを簡単に登録したい

* DBの作成

```
buner db:crete
```

* モデルの作成&DBマイグレーション

```
buner g model Task title:string description:text
buner db:migrate
```

* DB作成の確認

```
# DBコンソール
buner db
  select * from tasks; 
# Railsコンソール
buner c
  Task.all
  task = Task.new
  task.title = "Test"
  task.description = "Desc"
  task.save
  Task.all
  Task.find 1
```

* DBのロールバックができるか確認

```
buner db:migrate:redo STEP=1
buner db
  select * from tasks; 
  ->中身が空の状態
```

# Tips
## rails new の途中でエラーが発生しやり直す場合

* もう既にRailsプロジェクトがある旨のエラーが発生するので、以下で消してから再実行する
`rm -fr app bin config db lib log public test tmp config Rakefile`