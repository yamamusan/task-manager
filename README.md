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
* .gitignoreに`/public/packs`を追加する
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


## Step6:タスクモデルの初期作成

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
* なお、redoは指定されたポイントまでロールバックした上で再度マイグレーションを実行する

```
buner db:migrate:redo STEP=1
buner db
  select * from tasks; 
  ->中身が空の状態
```

## Step7:タスクのCRUD APIを作成しよう

### 仕様メモ

* /api/tasksのような名前空間を切る
* APIはとりあえず、以下の5つを作成する
  * GET        /tasks   -> index
  * GET        /tasks/1 -> show
  * POST       /tasks   -> create
  * PATCH/PUT  /tasks/1 -> update
  * DELETE     /tasks/1 -> destroy

### 作業の流れ
* app/controller/apiフォルダを作る
* とりあえずControllerを自動生成する(helperやassets(coffescript)などの作成はスキップする)

```
# model-nameを指定しないとapi::Task.allみたいなロジックなるため
buner g scaffold_controller api::task --model-name=task  --api
```

* 間違って自動生成した場合は以下で削除できる

```
buner destroy scaffold_controller api::task
```

* route.rbを修正(以下を追加.urlとmodule名にはapiを付与するが、自動生成系のメソッドプレフィックスにはつけない)

```
  scope :api, module: :api do
    resources :tasks, only: [:index, :show, :create, :update, :destroy]
  end
```

* scaffoldで生成された状態だと、API呼び出し時にエラーになるため修正を行う
  * xxxx.json.jbuilder -> tasks/task を taskに変更 

### 動作確認をどうするか

* get系のものは、rails consoleでActiveRecord経由でデータ突っ込んで、リクエスト投げれば良い
* 登録や更新系は自前で毎度JSON書くのはつらいのでREST clientを使いたくなる
* どうやらPOSTMANが一番メジャーっぽいのでそれを使うことにした

### 動かしてみたところ・・・

* [エラー]CSRF関連のエラーが帰ってきた
  *  `protect_from_forgery with: :null_session`をapplication_controller.rbに追加
  * ただし、これは一時的に回避策なので本来はちゃんとトークンを引き回すようなことをやるべき
* [想定外1]GETした際の結果に、タイトルや説明の項目が入ってこない
  * _task.json.jbuilderに出力項目として追加する必要があった
* [想定外2]POSTしたのに、タイトルなどが登録されていない
  * TasksControllerにpermitする処理を追加する必要があった

## 番外1: VueJSの開発環境を整備しましょう

### WebPackのコンパイルを自動化しよう

#### なぜやるのか
* 通常VueJS(というよりWebPack)関連のファイル(*.vueなど)を変更した場合は、`bin/webpack`でコンパイルする必要がある
* なお、`bundle exec rails s`をした際には、WebPackのコンパイルも同時に走っている
* 通常、`rails s` で起動した後、*.vueファイルを変えただけでは、画面に変更はされず、`bin/webpack`することで反映される
* これはめんどくさいので、`foreman`というgemを使って、コードを変更したらコンパイルが自動で走るようにする

#### 設定手順

* 事前に次のステップの「ルートアクセス時の画面を作成する」を実行する
* Gemfileに`gem 'foreman'`を追加する(Developmentグループに)
* `bundle install`を実行
* bin/serverというファイルを作成する

```
#!/bin/bash -i
bundle install
bundle exec foreman start -f Procfile.dev
```
* Procfile.devというファイルを作成する

```
web: bundle exec rails s
# watcher: ./bin/webpack-watcher
webpacker: ./bin/webpack-dev-server
```
* `chmod u+x bin/server`を実行しておく
* `bin/server`で起動する
* ポートが5000に変わるので、`http://localhost:5000`にアクセスすると画面が表示されるはず
* その状態で、Vueファイルを変更して再度画面にアクセスすると、変更が反映されているはず(画面開いていればリロードすらせずに反映される)

### VSCodeで.vueファイルのフォーマットを効かそう

* **Vetur** プラグインが入ってなければいれる
* Veturだけだとフォーマットが効かないので、**Prettier** というプラグインも入れる   
* User settingsに以下を追記して画面再ロード

```
    "prettier.singleQuote": true,
    "prettier.semi":false,
    "vetur.format.defaultFormatter.html": "js-beautify-html"
```
* `option + shift + F`　でフォーマットがきくようになる

## ステップ8: タスクを登録・更新・削除する画面を作成しましょう

### 仕組みの部分メモ

* Rails(vuejs版)では、`hello_vue.js`というファイルが存在する
* 上記ファイルでは、Vueインスタンスの生成や<app>との紐付けが設定されている
* ↓のルートアクセス時の画面作成では、index.html.erbがロードされたら、hello_vue.jsをロードするようにしている
* 実際の開発では、hello_vue.jsという名前は使われないので、同様の物を作り直すイメージ

### ディレクトリ構成を整える＆asset pipelineの廃止

* デフォルトのディレクトリ構成はいまいちなので、以下のようにディレクトリ構成を整える

```
#修正前
app
  L javascript
    L packs

#修正後
app
  L frontend
    L entry          ...entryのjsファイルをおくだけ
    L javascripts    ...javascriptファイル置き場
      L components   ...vueコンポーネントをおく場所
    L stylesheets    ...sassファイルをおく場所
    L images         ...画像ファイルを配置する
```

* 変える際のコマンドは以下。また、assets pipelineは使わないので削除

```
rm -fr app/assets
mv app/javascript app/frontend
mv app/frontend/packs app/frontend/entry
cd app/frontend
mkdir stylesheets
mkdir images
mkdir javascripts
touch stylesheets/application.css
touch javascripts/application.js
touch images/.keep
``` 

* config/webpacker.yml を以下のように修正し、ディレクトリの変更に追随する

```
 default: &default
-  source_path: app/javascript
+  source_path: app/frontend
-  source_entry_path: packs
+  source_entry_path: entry
```
* .jsや.cssを読み込むようにするため、`app/frontend/entry/application.js` でこれらを読み込むようにする

```
+import '../javascripts/application';
+import '../stylesheets/application';
+require.context('../images', true, /\.(png|jpg|jpeg|svg)$/);

console.log('Hello World from Webpacker')
```
* `app/views/layouts/application.html.erb`の以下２行を削除

```
    <%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track': 'reload' %>
    <%= javascript_include_tag 'application', 'data-turbolinks-track': 'reload' %>
```
 
### ルートアクセス時の画面を作成する

* 基本的に、Railsで用意するビューファイルは1つのみで、そこを差し替えていきます。  
まずは、以下のファイルを作成、編集します。(内容はソース参照)

  * app/controllers/home_controller.rb
  * config/routes.rb
  * app/views/home/index.html.erb

javascript_pack_tagを使用することで、app/frontend/javascript以下にあるJSファイルを探してくれます。  
インストール時にhello_vue.jsというファイルが生成されているので、これをindexにて読み込ませます。  
これで`bin/server`して、「Hello Vue!」と表示されれば大丈夫です。


### コンポーネントを使ってヘッダを作成する

* `index.html.erb`を編集する

```
<div id="app">
  <navbar></navbar>
</div>

<%= javascript_pack_tag 'applicatoin' %>
<%= stylesheet_pack_tag 'application' %>
```

* `mv app/frontend/javascripts/hello_vue.js app/frontend/javascripts/application.js`でリネーム
* 移動したファイルを以下の内容に編集し、Vueインスタンス作成し、index.html.erb内の<div id="app">にマウントされる

```
import Vue from 'vue/dist/vue.esm.js'

var app = new Vue({
  el: '#app',
});
```
* `mkdir -p app/frontend/javascripts/components` でコンポーネント用のディレクトリを作成
* 上記ディレクトリ内に `header.vue` を作成し、ヘッダ用のコンポーネントを作成する
* 内容は本体参照だが、ここでは、ロジックは不要なので、`<template>` でHTMLだけを記載する(初回はhogeとかでOK。)
* これを、`application.js`に登録(コンポーネントとして認識)させる(navbarという名前＝タグ名で登録)

```
import Vue from 'vue/dist/vue.esm.js'
+ import Header from './components/header.vue'

var app = new Vue({
   el: '#app',
+  components: {
+    'navbar': Header,
+  }
 });
```

* サーバを再起動して、`http://localhost:5000`にアクセスするとヘッダだけが表示されるはず
* この状態で、`header.vue`を修正していくと、即反映されるので開発が捗る

### コンポーネントから画像を参照する

* `app/frontend/images`にmaterial designのface画像を配置
* この画像を`header.vue`から参照して、表示させる
* 以下のように記載すればOK 

```
 <img src="../../images/user.png">
```

### CSSフレームワークを導入しましょう

* 後のタイミングでも良いのだが、導入はここでやっといて、細かくデザインを凝るのはあとやる
* 今回は一番スタンダード(ちょっと下火っぽいけど)なbootstrapを使ってみる(バージョンは4)
* gemでbootstrapを入れる方法もあるが、assets pipelineをやめたのでyarnを使って入れる

```
yarn add bootstrap@4.1.1 font-awesome jquery tether popper.js
```
*  `app/frontend/javascripts/application.js`の先頭に以下を記載

```
import 'bootstrap/dist/js/bootstrap'
```
*  `app/frontend/stylesheets/application.scss`の先頭に以下を記載

```
@import '~bootstrap/dist/css/bootstrap';
$fa-font-path: "~font-awesome/fonts";
@import '~font-awesome/scss/font-awesome';
```
* `header.vue` にbootstrapのクラスとかを指定して、反映されていることを確認する
* `bin/server`でサーバを起動すると、ヘッダの画面にもスタイルが適用されていることがわかるはず

### BootStrapのCSSをカスタマイズするには

* BootStrapが提供するスタイルをカスタマイズする方法は以下の３つがある
  * すでに用意されているスタイル・コンポーネントをそのまま使う
    * これはカスタマイズでもない。
    * ザBootStrapな画面に
  * すでに用意されているスタイル・コンポーネントをそのまま使う
    * 定義済みのCSSを継承して、元のデザインを変更する
  * すでに用意されているスタイル・コンポーネントをカスタマイズしつつ、Bootstrapで用意されているAPI（Sass, Less）を使ってカスタムコンポーネントを定義する。
    * 既存コンポーネントから独自コンポーネントを作ることができます。
    * 機能は同じだけど、クラス名を変更したコンポーネントを作れたり、グリッドシステムを自作できたり。
    * CSSプリプロセッサをわかってないとカスタマイズできないので、難易度高め。
* 2こめのやつが現実的
* 例えば、application.scssに以下のような感じで記載することで、既存のクラスの設定値を変えたり、別のクラスで上書きしたりできる

```css
// 別のクラスを使って上書き
.taskul-nav-color {
  background-color:#39DCE6;
}

// bootstrapの既存クラスの値を書き換え
.navbar {
  padding: 0.1rem 1rem;
}
```

参考：http://blog.yuhiisk.com/archive/2016/03/22/customize-the-css-of-bootstrap.html
参考：https://creive.me/archives/9316/

### ルーティングによる画面の切り替え

* Vue-Routerを使用することで、登録されたパスとコンポーネントで画面内を差し替えることができます。
* yarnを使ってvue-routerを追加します。

```
yarn add vue-router
```
* ひとまず、一覧画面のコンポーネントの雛形を作ります
  * この時点では、ルーティングされることの確認なので中身はなんでもOK
  * ファイル名は`task-list.vue`としてみる
* 次にこのコンポーネントとパスを登録するrouter.jsを`frontend/javascripts`以下に作成

```
import Vue from 'vue/dist/vue.esm.js'
import VueRouter from 'vue-router'
import TaskList from 'components/task-list.vue'
 
Vue.use(VueRouter)
 
export default new VueRouter({
  mode: 'history',
  routes: [
    { path: '/', component: TaskList },
  ],
}
```

* 最後に`frontend/javascripts/application.js`に以下を追加し、exportしたRouteオブジェクトをrouterとして登録する

```
import 'bootstrap/dist/js/bootstrap'
import Vue from 'vue/dist/vue.esm.js'
+ import Router from 'router.js'
import Header from './components/header.vue'

var app = new Vue({
+ router: Router,
  el: '#app',
  components: {
    'navbar': Header,
  }
});
```

### ひとまず一覧画面の枠を作成する（まだServerから情報はもらわない）

* 前の手順で作成した`task-list.vue`について、画面をそれっぽく作ってみる
* ここは、bootstrap(必要に応じてカスタマイズ),vue jsの機能を活用して実装していく
* vue jsのデータはダミーで積んでおく(後ほどAPI呼び出しにする)

### 振る舞いの仕様をrspecで書いていく

#### テストの方針

* ホワイトボックスよりのテストはモデルとヘルパーのUnitテスト
* E2EテストはCapybaraベースで
* APIに関するテストはRequest　Specを使う？
* 以下のテストは実施しない
  * コントローラ(+モデル)のテスト(機能テスト)
* テストデータの管理にはfactory-botを使用する
* Turnipでテスト仕様(受け入れ条件)を書いていく
* Outsite-inの原則に乗っ取り、E2E風なテストから実装していく
* (TODO)Rspec RailsにSystemSpecというE2Eの機能が入ったみたいだが、今回はそこまでやれなそう

#### RSpecのセットアップ

* Gemfileを以下のように編集して、`buner install`を実施

```
group :development, :test do
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "guard-rspec"
  gem "spring-commands-rspec"
  gem 'turnip'
end

group :test do
  gem "faker"
  gem "capybara"
  gem "selenium-webdriver"
  gem 'chromedriver-helper'
  gem "database_cleaner"
  gem "launchy"
  gem "shoulda-matchers"
end
```

* `rspec-rails` は RSpec を含んでいる gem である。この gem は Rails 専用の機能を追加する RSpec の ラッパーライブラリになっている。
* `factory_bot_rails` は Rails がデフォルトで提供するフィクスチャをずっと便利な ファクトリ で置き換える。フィクスチャやファクトリはテストスイート用のテストデータを作成するために使われる。
* `guard-rspec` は指定されたファイルを監視する。そして監視対象のファイルに応じてタスクを実行する。
* `spring-commands-rspec` は Spring に bin/rspec コマンドのサポートを追加する。
* `faker` は名前やメールアドレス、その他のプレースホルダを ファクトリ に提供する。
* `capybara` はユーザと Web アプリケーションのやりとりをプログラム上で簡単にシミュレートできるようにする。
* `selenium-webdriver` はブラウザ上で JavaScript を利用する機能を Capybara でテストできるようにする。
* `chromedriver-helper` はChromeのドライバーを実行できるようになる.
* `database_cleaner` はまっさらな状態で各 spec が実行できるように、テストデータベースのデータを掃除する。
* `launchy` はあなたの好きなタイミングでデフォルトの webブラウザを開き、アプリケーションの表示内容を見せる。テストをデバッグするときには 大変便利である。
* `shoulda-matchers` は数多くの便利なマッチャを自動的に使えるようにする。

参考：https://qiita.com/Morinikiz/items/cf179583c2c5d2e24c3c


* Rspec用のディレクトリを作成する

```
buner g rspec:install
mkdir -p spec/features spec/steps
```

* `buner g model <モデル名>` でrspec用のテストクラスやファクトリクラスも作ってくれる
* 今回はすでにtaskモデルを作成済みだが、`buner g model task --skip`で必要なテスト部分だけ生成してくれる

* また、準備として、`.rspec`に以下の記載を追加する

```
--format documentation
--require turnip/rspec
```
* また、`spec_helper.rb`に以下の記載を追加する

```
Dir.glob("spec/**/*steps.rb") { |f| load f, true }

# Capybara自体の設定、ここではどのドライバーを使うかを設定しています
Capybara.configure do |capybara_config|
  capybara_config.default_driver = :selenium_chrome
  capybara_config.default_max_wait_time = 10 # 一つのテストに10秒以上かかったらタイムアウトするように設定しています
end
# Capybaraに設定したドライバーの設定をします
Capybara.register_driver :selenium_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('headless') # ヘッドレスモードをonにするオプション
  options.add_argument('--disable-gpu') # 暫定的に必要なフラグとのこと
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.javascript_driver = :selenium_chrome
```

#### RSpecにE2Eのテストを書いてみる

* まず、`spec/features/top.feature`に仕様を書いていく

```
# encoding: utf-8
# language: ja

@common
機能: トップ画面
  トップ画面に関するテストです。

  @new
  シナリオ: トップ画面で新規登録を押すと、登録画面が表示される
    もし    トップ画面にアクセス
    かつ    新規登録ボタンを押下
    ならば   新規登録画面が表示される 

  @search
  シナリオ: トップ画面で詳細検索ボタンを押すと、詳細検索画面が表示される
    もし    トップ画面にアクセス
    かつ    詳細検索ボタンを押下
    ならば   詳細検索画面が表示される 
```

* 次に、`spec/steps/top_steps.rb`に実施のテストコードを書いていく

```
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
    visit root_path
  end
end

steps_for :search do
  step '詳細検索ボタンを押下' do
    visit root_path
    click_button '詳細検索'
  end

  step '詳細検索画面が表示される' do
    visit root_path
  end
end
```

* 以下でfeatureのテストを実行する

```
bundle exec rspec spec/features/top.feature
```

* エラーにならなければとりあえず導入はOK.(エラーにならないようなテストケースにしているので)
* 準備が整ったので、あとは実際の期待すべき仕様を書いていく。が、その前にユニットテストを書いていく


#### ユニットテストを書いていく

##### 方針

* ユニットテストは内部的な挙動の話なので、turnipは使わない
* rspecでモデルに対するSpecを普通に書いていく
* 対象は`spec/models/task_spec.rb`
* モデルスペックに含める内容(結構ActiveRecordがやってくれるので意外とやることないな)
  * 有効な属性が渡された場合、モデルのcreateメソッドが正常に完了すること。
  * バリデーションを失敗させるデータがあれば、正常に完了しないこと。
  * クラスメソッドとインスタンスメソッドが期待通りに動作すること。

##### HelloWorldレベル

* FactoryBotの記述(spec/factories/tasks.rb)

```
FactoryBot.define do
  factory :base, class: "Task" do
    title "Hello" 
    description "Hello" 
  end
end
```

* ひとまず、上記のデータを活用したちょっとしたテストを書いてみる(spec/models/task_spec.rb)

```
  # let(:base) { FactoryBot.build(:base) }  # メモリ上に展開
  let(:base) { FactoryBot.create(:base) }

  example 'hoge' do
    expect(base.title).to eq 'Hello'
    expect(Task.find(1).title).to eq 'Hello'
  end

  example 'hoge2' do
    p base
    p Task.all
  end
```
* `buner rspec spec/models/`でテストを実行
* 以下のような挙動になる模様
  * テストの実行前に毎度letメソッドの結果が保持される
    * つまり、とあるexampleでletの値をいじっても次のテストに影響はない

* FactoryBot.buildと書くのはだるいので、以下のような記述を`spec_helper.rb`に追記
* これでbuildやcreateのような感じで呼び出せるようになる

```
 # ファクトリを簡単に呼び出せるよう、Factory Girl の構文をインクルードする
 config.include FactoryBot::Syntax::Methods
```

##### 実践編

* taskモデルに対するテスト
  * バリデーション
    * タイトルは必須、説明は任意
    * タイトルは256文字以上はエラー 
* テストを実行すると当然エラーになる
* 以下のようにtask.rbにバリデーションを追加する
  * `validates :title, presence: true, length: { maximum: 256 }`
* テストを実行すると、全てOKになるはず。これがTDDや！！！

### BackEndの処理を実装していきましょう！

#### 一覧画面とAPIと処理の関連を考えてみる

|No|画面側の操作|API(URL)|処理のイメージ|
|:--:|:--|:--|:--|
|1|初期表示,ステータスボタン押下,詳細検索|GET /api/tasks|指定された条件でAND検索.条件が一つもなければ全件検索。ソート順はとりあえずID|
|2|新規登録ボタン押下|-|-|
|3|詳細検索ボタン押下|-|-|

#### 1のバックエンドについての設計

* 条件が指定されてなければallだが、指定されてたら指定された条件のみ連結してANDでつなぐ形になる
* controllerでこれを普通に実装しようとすると、if地獄になり、Fat Controllerになってしまう
* なので、model側でSQLの組み立てを行うようなイメージでやりたい
* フィジビリティ確認のために、modelに以下の実装を入れてみる

```
  scope :title_like, ->(title) { where('title like ?', "%#{title}%") if title.present? }
  scope :description_like, ->(description) { where('description like ?', "%#{description}%") if description.present? }

  def search
    Task.title_like(self.title).description_like(self.description)
  end
```
* 上記に対して、例えば以下のように呼び出すと、結果的に条件が指定されている項目だけAND検索される

```
# taskは検索条件がはいったtaskインスタンス
task.search
```

* 上記で期待通りの挙動をしそうな感じ
* なので、上記に対するテストを作成する
  * テストデータはFactoryBotで書く(データを４つほど用意する)
  * あとは、rspecに以下のようなテストを作成する

```
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
```

* 続いて、コントローラに作成したtask#searchメソッドの呼び出し処理を追加する

```
  def index
    condition = Task.new(search_params)
    @tasks = condition.search
  end

  ・・・

    def search_params
      params.permit(:title, :description) 
    end
```

* (本当はAPIに対するテストを書いた方がいいんだろうけど)ひとまずPOSTMANで動作確認
  * `http://localhost:5000/api/tasks?title=jenkins&description=nice' とかで期待通りに帰って来ればOK


#### 優先度、ステータス、期限という項目がtaskモデルにないので追加する

* 優先度やステータスについては、値はコードで持たせて、表示する際などは名称を使いたい(つまりコード値の考え方)
* railsでこれをやる場合は、enumが使えそう
* ということでそれを踏まえて、やってみる

* `buner g migration AddColumnsToTask priority:integer status:integer due_date:date`でマイグレーションファイル雛形作成
* マイグレーションファイルを以下のように編集(タイトルとstatusをNotNullに)

```
class AddColumnsToTask < ActiveRecord::Migration[5.2]
  def change
    change_column :tasks, :title, :string, null: false
    add_column :tasks, :priority, :integer
    add_column :tasks, :status, :integer, default: 0, null: false
    add_column :tasks, :due_date, :date
  end
end
```
* `buner db:migrate:reset`で最初からマイグレーションやり直し(大したデータ入ってないので)
* 次に、task.rbに以下のようにenumの定義を追加

```
  enum priority: { normal: 0, low: -1, high: 1 }, _prefix: true
  enum status: { todo: 0, doing: 1, done: 2 }, _prefix: true
```
* 上記をやって、railsコンソールで動きを確認してみる

```
Task.statuses
=> {"todo"=>0, "doing"=>1, "done"=>2}

t = Task.new
irb(main):002:0> t.status
=> "todo"
irb(main):003:0> t.status_todo?
=> true
irb(main):004:0> t.status_doing?
=> false

# 値を設定する方法(1)
irb(main):004:0> t = Task.new(status: :status_doing, priority: :priority_high)
# 値を設定する方法(2) →　ただし、このタイミングでDBへのsaveが走る模様
irb(main):004:0> t.status_done!

# 元の値を数値で取得する方法(あまり数値を意識する必要ないのかな？でも画面で10:xxxみたいに出したいときは困るよね)
irb(main):004:0> t.status_before_type_cast
```

* ちなみにシステム側で決め打ちできるものなら上記で良いが、例えばRedmineのように利用者側で優先度をカスタマイズしたい場合などはDBに持たす必要あり
* ちなみに表示されるのは英語になるので、日本語化したい場合は `enum_help` というgemを使うらしい(i18n対応は後ほど)

#### 優先度、ステータス、期限という項目のバリデーションを定義する

* 以下のような方針とする
  * 優先度とステータスはenumなので、特にチェックしない
  * 期限は現在日より後ろの場合はNGとする
* 上記の設定をまずはrspecに書いていく
* が、その前にFactoryの定義を変えよう!

```
FactoryBot.define do
  # nestすることで共通化ができる
  factory :base, class: 'Task' do
    title 'This is Title'
    description 'Description'
    status :doing
    priority :normal

    factory :data1, class: 'Task' do
      title 'Jenkins'
      description 'Jenkins is cool'
    end
    ...
  end
end
```

* 次に追加した項目のバリデータション関連のspecをテストに書いていく

```
    describe 'ステータス' do
      context '未入力の場合' do
        before { base.status = nil }
        example 'エラーになること' do
          expect(base).to be_invalid
        end
      end
    end

    describe '期限' do
      context '昨日の場合' do
        before { base.due_date = Date.yesterday }
        example 'エラーになること' do
          expect(base).to be_invalid
        end
      end
      context '今日の場合' do
        before { base.due_date = Date.today }
        example 'エラーにならないこと' do
          expect(base).to be_valid
        end
      end
      context '明日の場合' do
        before { base.due_date = Date.tomorrow }
        example 'エラーにならないこと' do
          expect(base).to be_valid
        end
      end
    end
 ```

* 流すとエラーになるので、モデルにバリデーションを追加していく

```
  validates :status, presence: true
  validate :not_before_today
  ...
  def not_before_today
    errors.add(:due_date, 'Please set today or after today') if due_date.present? && due_date < Date.today
  end
```

#### 優先度、ステータス、期限という項目も検索条件に加えておく

* 期限は使うかわからんので、とりあえず今は優先度とステータスのみを入れる
* 優先度とステータスはきっと複数選択されることを想定しておく
* まず、テストを作る

```
    context 'ステータス指定がある場合' do
      example '存在しない場合は空が返る' do
        task.statuses = [Task.statuses[:done]]
        expect(task.search.size).to eq 0
      end

      example '存在する場合は対象レコードが返る' do
        task.statuses = [Task.statuses[:doing]]
        expect(task.search).to match_array [data1, data2, data4]
      end

      example 'IN検索になっていること' do
        task.statuses = [Task.statuses[:doing],Task.statuses[:todo]]
        expect(task.search).to match_array [data1, data2, data3, data4]
      end
    end

    context '優先度指定がある場合' do
      example '存在しない場合は空が返る' do
        task.priorities = [Task.priorities[:high]]
        expect(task.search.size).to eq 0
      end

      example '存在する場合は対象レコードが返る' do
        task.priorities = [Task.priorities[:normal]]
        expect(task.search).to match_array [data1, data2, data3]
      end

      example 'IN検索になっていること' do
        task.priorities = [Task.priorities[:normal],Task.priorities[:low]]
        expect(task.search).to match_array [data1, data2, data3, data4]
      end
    end
```
* 当然エラーになるので、モデルに以下のような実装を追加

```
  attr_accessor :statuses, :priorities
  ...
  scope :status_in, ->(statuses) { where(status: statuses) if statuses.present?}
  scope :priority_in, ->(priorities) { where(priority: priorities) if priorities.present?}
```
* controllerにpermitの定義を追加

```
  def task_params
    params.fetch(:task, {}).permit(:title, :description, :status, :priority)
  end
  def search_params
    params.permit(:title, :description, statuses: [], priorities: [])
  end
```
* json.builderにも出力項目として追加

### そろそろデバッグをしてみよう

* Rails Panel(chrome拡張)
  * Gemfileに `gem 'meta_request'` を追加してbundle install(development)
  * Chrome拡張をインストール
  * DevToolを開くと、リクエスト毎のログやSQLなどが見れる。便利！
* pry-byebug
  * Gemfileに `gem 'pry-byebug'` を追加してbundle install(development)
  * break-poingに `binding.pry` というコードを入れる
  * そこを通過するようなAPIを叩くまたはコンソールからキックする
  * すると以下のようなコンソールが現れる

```
21:49:19 web.1       |      8: def index
21:49:19 web.1       |      9:   condition = Task.new(search_params)
21:49:19 web.1       |     10:   binding.pry
21:49:19 web.1       |  => 11:   @tasks = condition.search
21:49:19 web.1       |     12: end
```
  * condtion の中身をみたい場合は以下のように打つ 

```
condition
21:49:51 web.1       | => #<Task:0x00007f8972d1f058
21:49:51 web.1       |  id: nil,
21:49:51 web.1       |  title: "jenkins",
21:49:51 web.1       |  description: nil,
21:49:51 web.1       |  created_at: nil,
21:49:51 web.1       |  updated_at: nil,
21:49:51 web.1       |  priority: nil,
21:49:51 web.1       |  status: "todo",
21:49:51 web.1       |  due_date: nil>
```

  * 以下のようなコマンドが使える。finishはメソッドを抜ける感じ
    * next : 次の行を実行
    * step : 次の行かメソッド内に入る
    * continue : プログラムの実行をcontinueしてpryを終了
    * finish : 現在のフレームが終わるまで実行
  * 今回はやってないが、~/.pryrcを作成しておくと楽です

```
if defined?(PryByebug)
  Pry.commands.alias_command 's', 'step'
  Pry.commands.alias_command 'n', 'next'
  Pry.commands.alias_command 'f', 'finish'
  Pry.commands.alias_command 'c', 'continue'
end
```

* Web Console
  * Railsにデフォルトで入っているみたい
  * どうやら返すHTMLの中に埋め込むっぽいので、APIアプリだとダメっぽいな・・

* VSCode上でデバッグするには？
  * まず、Gemfileに以下を追加(developmentでいいかな)し、`budle install`

```
gem 'ruby-debug-ide'
gem 'debase'
```
  * debugメニューから歯車アイコンを選択して、launch.jsonを以下のように編集

```
    {
      "name": "Listen for rdebug-ide2",
      "type": "Ruby",
      "request": "attach",
      "cwd": "${workspaceRoot}",
      "remoteHost": "127.0.0.1",
      "remotePort": "1234",
      "remoteWorkspaceRoot": "${workspaceRoot}",
    },
``` 
  * `bundle exec rdebug-ide --host 127.0.0.1 --port 1234 --dispatcher-port 26162 -- bin/rails s`で実行
  * デバッガを起動すると、プロセスが先に進み始める
  * あとは、画面でブレークポイントを仕掛ければOK。なはずだが、なぜかスルーされてしまう・・
  * ★★★★原因不明。★★★★


### 画面とサーバをつないで、APIで一覧データを取得するようにする
  
* `yarn add axios`でAPI用のライプラリを入手
*  以下のようにAPI呼び出し

```
export default {
  name: 'tasks',
  data() {
    return {
      tasklist: []
    }
  },
  mounted: function() {
    this.fetchTasks()
  },
  methods: {
    fetchTasks: function() {
      axios.get('/api/tasks').then(
        response => {
          for (let i = 0; i < response.data.length; i++) {
            this.tasklist.push(response.data[i])
          }
        },
        error => {
          console.log(error)
        }
      )
    }
  }
}
```

* なお、GETでパラメータを渡す場合は、URLに積む方法と以下のようにあパラメータを引数に渡す方法がある模様

```
      const params = { priorities: ['high'] }
      axios.get('/api/tasks', { params: params }).then(
```
* イベントハンドリングのはじめとして、ステータスボタンを押したらそれに絞り込んでみる(もっと良い方法がありそうだが・・・)

```
  <button type="button" class="btn btn-primary btn-sm" @click="statusGet('todo')">未着手</button>
  <button type="button" class="btn btn-secondary btn-sm" @click="statusGet('doing')">着手</button>
  <button type="button" class="btn btn-success btn-sm" @click="statusGet('done')">完了</button>
...
  statusGet: function(status){
    this.tasklist = []
    this.statuses.includes(status) || this.statuses.push(status)
    let params = { statuses: this.statuses }
    this.fetchTasks(params)
  },
  fetchTasks: function(params) {
    axios.get('/api/tasks', {params: params}).then(
``` 

### 初期データを積んでみよう

* `seeds.rb`を作成.Fakerを使って、ランダムデータを積んでみる

```
10.times do |_n|
  title = Faker::Lorem.sentence
  description = Faker::Lorem.paragraph
  status = [0, 1, 2].sample
  priority = [-1, 0, 1].sample
  Task.create!(title: title, description: description, status: status,
               priority: priority)
end
```

* `buner db:seed`を実行し、１０件分のランダムデータを積む

### vuejsでもJQueryを使えるようにする

* モーダルをjavascriptで操作する際にjqueryが使えないときついので、`environment.js`に以下記載を追加することで使えるようになる

```
const webpack = require('webpack')
environment.plugins.append(
  'Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    Tether: 'tether',
    'window.Tether': 'tether',
    Popper: ['popper.js', 'default']
  })
)
```

### モーダルな登録画面を作成しよう

* bootstrapのモーダルを使って子画面を作成する
* ステータスや優先度は何もしないと文字列型としてPOSTされて、サーバ側でエラーになるの`v-model.number`とすればOK

```
    <div class="modal fade" id="task-register" tabindex="-1">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">新しいタスクを作成</h5>
          </div>
          <div class="modal-body">
            <form>
              <div class="form-group">
                <label for="title">タイトル</label>
                <input type="text" class="form-control" v-model="task.title" id="title">
              </div>
              <div class="form-group">
                <label for="description">説明</label>
                <textarea rows="3" class="form-control" v-model="task.description" id="description"></textarea>
              </div>
              <div class="form-group">
                <label for="priority">優先度</label>
                <select class="custom-select" v-model.number="task.priority" id="priority">
                  <option value="-1">低</option>
                  <option value="0" selected>中</option>
                  <option value="1">高</option>
                </select>
              </div>
              <div class="form-group">
                <label for="status">ステータス</label>
                <select class="custom-select" v-model.number="task.status" id="status">
                  <option value="0" selected>新規</option>
                  <option value="1">着手</option>
                  <option value="2">完了</option>
                </select>
              </div>
            </form>
            <button class="btn btn-primary pull-right" @click="registerTask">新規登録</button>
          </div>
        </div>
      </div>
    </div>
```

* javascriptは以下のような感じ

```
  data() {
    return {
      tasklist: [],
      statuses: [],
      task: {
        title: '',
        description: '',
        status: 0,
        priority: 0
      }
    }
  ...
     registerTask: function() {
      axios.post('/api/tasks', this.task).then(
        response => {
          $('#task-register').modal('hide')
          this.fetchTasks()
        },
        error => {
          console.log(error)
        }
      )
    },
 ```

### 更新画面を実装しよう

* 登録画面と更新画面は中身がほとんど同じなのでコンポーネント化してみよう!

#### コンポーネントの作成

* task-form.vueというファイル名
* task-list.vueのモーダル部分のコードをコピペ
* 親側(コンポーネント利用側) で以下のようにインポートする

```
import TaskForm from './task-form.vue'

export default {
  name: 'tasks',
  components: {
    TaskForm,
  },
 ```
* そうすると以下のようにケバブケースでタグが利用できる

```
<task-form></task-form>
```

#### 子コンポーネントにパラメータを渡す

* 子側では、以下のようにprops属性を定義してあげる

```
export default {
  name: 'taskform',
  props: {
    type: {
      type: String,
      required: false
    }
  },
 ```
* 親側では、以下のように属性に定義してあげればよい(:typeにした場合は、スクリプトの結果を渡せる)

```
<task-form type="register" @reload="fetchTasks"></task-form>
```

* 上記のパラメータを使って、以下のように`v-if`で登録・更新モードを切り分ける

```
 <div v-if="type === 'register'">
   <h5 class="modal-title">新しいタスクを作成</h5>
 </div>
 <div v-else>
   <h5 class="modal-title">タスクを更新</h5>
 </div>
```

#### 子から親のメソッドを呼び出す方法

* 親側では以下のように、カスタムイベント名とそれで呼ばれるメソッド名を定義する

```
<task-form type="register" @reload="fetchTasks"></task-form>
```
* 子側では以下のように、emitでカスタムイベントを発火させてあげる

```
this.$emit('reload')
```

#### 親から子のメソッドを呼び出す方法

* 親側では以下のように、コンポーネントのオブジェクトを特定する名前(ref)をつける

```
<task-form type="update" @reload="fetchTasks" ref="updatemodal"></task-form>
```
* 親側で以下のようにrefを特定して、そこから子のメソッドを呼んであげればOK

```
openTaskModal: function(id) {
  this.$refs.updatemodal.openModal(id)
  $('#task-update').modal('show')
},
```

#### 更新画面を完成させる

* 長いので`b5a4834` のコミットを参照

### 削除機能の実装

* 一括チェックするjavascriptの実装

```
  checkAll: function() {
    $('.checkbox-list').prop('checked', $('#checkbox-header').prop('checked'))
  }
```

* 削除APIの呼び出し
  * routingをどうするか？一旦DELETEのコレクションリソースを追加　

```
  scope :api, module: :api, format: 'json' do
    resources :tasks, only: %i[index show create update] do
      delete :index, on: :collection, action: :delete
    end
  end
 ```
 *　あとは、Controllerに削除アクションを追加して、javascriptでチェックされたID配列を送ってあげればOK

### FeatureSpecを更新しましょう！！

* 更新機能等もやるので、初期データはFactoryBotを使う
* ただ、そうするとテストをするたびにデータが溜まってしまうので以下のようにデータクリーンを入れる

```
steps_for :common do
  step 'トップ画面にアクセス' do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
    visit root_path
  end
end
```
* ひとまず以下のシナリオを追加(整備)

```
  シナリオ: トップ画面で新規登録ボタンを押して、登録画面を表示して登録を行う
  シナリオ: トップ画面でタスクを選択して、更新を行う
  シナリオ: トップ画面でタスクを選択して、削除を行う
  シナリオ: トップ画面で一括選択チェックボックスを選択
```

### Slotを使って汎用モーダルを作ろう　


### BootStrapの画面をレスポンシブにする(グリッドシステム)

### ransnackを使って、検索機能を置き換えてみよう(詳細検索機能を追加しよう)


### 更新履歴をみられるようにしよう(has_many)


### テーブルじゃなくて、カード表記にしよう




# tips
## rails new の途中でエラーが発生しやり直す場合

* もう既にrailsプロジェクトがある旨のエラーが発生するので、以下で消してから再実行する
`rm -fr app bin config db lib log public test tmp config rakefile`

## capybaraのテスト時にfirefoxを使う場合

* 今回はchromeのヘッドレスドライバを使ったが、標準だとfirefoxになる雰囲気
* その場合は、色々面倒な設定やインストールが必要だった
  * gemfileに`gem "capybara-webkit"`を入れる
  * firefoxをインストール(今回はこれが嫌だったのでやめた)
  * 以下のコマンドを実行し、色々インストール
```
brew install qt@5.5
ln -s /usr/local/cellar/qt@5.5/5.5.1_1/bin/qmake /usr/local/bin/qmake
```
  * spec_helper.rbに以下の設定を追加 

```
actioncontroller::base.asset_host = "http://localhost:3000"
capybara.default_driver = :selenium
config.include capybara::dsl
```

## rspecで特定のケースだけ実施したい場合

http://o.inchiki.jp/obbr/175

 