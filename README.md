# Required

* Ruby 2.5.1
* Rails 5.2.0
* NodeJS 8.11.1
* Yarn

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

# Tips

## rails new の途中でエラーが発生しやり直す場合

* もう既にRailsプロジェクトがある旨のエラーが発生するので、以下で消してから再実行する
`rm -fr app bin config db lib log public test tmp config Rakefile`