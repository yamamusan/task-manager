<template>
  <div>
    <nav class="navbar navbar-dark navbar-expand-lg taskul-nav-color">
      <a class="navbar-brand" href="#">Taskul</a>

      <!-- レスポンシブデザイン用に画面サイズが小さくなったらdata-targetのブロックを隠し、右側にメニューを表示する -->
      <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
      </button>

      <!-- Bootstrapのドロップダウンメニューを利用。中のテキストは画像にしている -->
      <div class="collapse navbar-collapse" id="navbarSupportedContent">
        <ul class="navbar-nav ml-auto">

          <li class="nav-item dropdown">
            <a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
              <!-- イメージを直接表示する場合 -->
              <img src="~images/user.png" class="img-fluid">
              <!-- イメージもCSS化する場合は以下のような感じ　-->
              <!-- <div id="taskul-user" class="img-fluid"></div> -->
            </a>
            <div class="dropdown-menu dropdown-menu-right" aria-labelledby="navbarDropdown">
              <a class="dropdown-item" href="#">プロフィール</a>
              <a class="dropdown-item" href="#">アカウント管理</a>
              <div class="dropdown-divider"></div>
              <a class="dropdown-item" href="#">Something else here</a>
            </div>
          </li>
        </ul>

        <!-- <ul class="navbar-nav mr-auto">
          <li class="nav-item active">
            <a class="nav-link" href="#">Home
              <span class="sr-only">(current)</span>
            </a>
          </li>
          <li class="nav-item">
            <a class="nav-link" href="#">Link</a>
          </li>
         <li class="nav-item">
            <a class="nav-link disabled" href="#">Disabled</a>
          </li>
        </ul>
        <form class="form-inline my-2 my-lg-0">
          <input class="form-control mr-sm-2" type="search" placeholder="Search" aria-label="Search">
          <button class="btn btn-outline-success my-2 my-sm-0" type="submit">Search</button>
        </form> -->

      </div>
    </nav>

    <!-- <button type="button" class="btn btn-primary btn-lg" data-toggle="modal" data-target="#myModal">
      Launch demo modal
    </button>

    <div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
      <div class="modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
              <span aria-hidden="true">&times;</span>
            </button>
            <h4 class="modal-title" id="myModalLabel">Modal title</h4>
          </div>
          <div class="modal-body">
            ...
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
            <button type="button" class="btn btn-primary">Save changes</button>
          </div>
        </div>
      </div>
    </div>
 -->

    <!-- Jumbotronと呼ばれるBootstrapのパーツ使う場合 -->
    <!-- <div class="jumbotron">
      <div class="container-fluid">
        <h1>Hoge!!kk</h1>
        <p>
          <a class="btn btn-primary btn-lg" href="#" role="button">CONTACT ME</a>
        </p>
      </div>
    </div>
    -->

  </div>
</template>

