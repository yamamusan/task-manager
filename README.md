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
* 内容は本体参照だが、ここでは、ロジックは不要なので、<template>でHTMLだけを記載する(初回はhogeとかでOK。)
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


# Tips
## rails new の途中でエラーが発生しやり直す場合

* もう既にRailsプロジェクトがある旨のエラーが発生するので、以下で消してから再実行する
`rm -fr app bin config db lib log public test tmp config Rakefile`